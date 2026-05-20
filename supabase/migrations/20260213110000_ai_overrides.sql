-- ═══════════════════════════════════════════════════════
--  AI RECOMMENDATIONS + OVERRIDE TABLES
-- ═══════════════════════════════════════════════════════

-- 1) AI Recommendations (output from AI backend)
CREATE TABLE IF NOT EXISTS public.ai_recommendations (
  id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  type            public.recommendation_type NOT NULL,
  payload_json    jsonb NOT NULL DEFAULT '{}'::jsonb,
  order_id        uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  task_id         uuid REFERENCES public.operation_tasks(id) ON DELETE SET NULL,
  delivery_id     integer REFERENCES public.deliveries(delivery_id) ON DELETE SET NULL,
  created_at      timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_ai_rec_type      ON public.ai_recommendations (type);
CREATE INDEX IF NOT EXISTS idx_ai_rec_order      ON public.ai_recommendations (order_id);
CREATE INDEX IF NOT EXISTS idx_ai_rec_task       ON public.ai_recommendations (task_id);
CREATE INDEX IF NOT EXISTS idx_ai_rec_delivery   ON public.ai_recommendations (delivery_id);
CREATE INDEX IF NOT EXISTS idx_ai_rec_created    ON public.ai_recommendations (created_at DESC);

-- 2) Override Decisions (one per recommendation, enforced by UNIQUE)
CREATE TABLE IF NOT EXISTS public.override_decisions (
  id                      uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  recommendation_id       uuid NOT NULL REFERENCES public.ai_recommendations(id) ON DELETE CASCADE,
  status                  public.override_status NOT NULL,
  overridden_by_user_id   uuid NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
  justification           text NOT NULL CHECK (char_length(justification) > 0),
  final_payload_json      jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at              timestamptz DEFAULT now() NOT NULL,
  updated_at              timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT uq_one_decision_per_recommendation UNIQUE (recommendation_id)
);

CREATE INDEX IF NOT EXISTS idx_override_dec_user    ON public.override_decisions (overridden_by_user_id);
CREATE INDEX IF NOT EXISTS idx_override_dec_status  ON public.override_decisions (status);

-- 3) Recommendation Feedback (append-only, reward = +1 or -1)
CREATE TABLE IF NOT EXISTS public.recommendation_feedback (
  id                  uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  recommendation_id   uuid NOT NULL REFERENCES public.ai_recommendations(id) ON DELETE CASCADE,
  reviewer_user_id    uuid NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
  reward              smallint NOT NULL CHECK (reward IN (-1, 1)),
  comment             text,
  created_at          timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_rec_feedback_rec  ON public.recommendation_feedback (recommendation_id);
CREATE INDEX IF NOT EXISTS idx_rec_feedback_user ON public.recommendation_feedback (reviewer_user_id);

-- RLS
ALTER TABLE public.ai_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.override_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_feedback ENABLE ROW LEVEL SECURITY;

-- Policies: read for all authenticated, write via service role
CREATE POLICY "Anyone can read ai_recommendations"
  ON public.ai_recommendations FOR SELECT USING (true);
CREATE POLICY "Service can insert ai_recommendations"
  ON public.ai_recommendations FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can read override_decisions"
  ON public.override_decisions FOR SELECT USING (true);
CREATE POLICY "Service can manage override_decisions"
  ON public.override_decisions FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can read recommendation_feedback"
  ON public.recommendation_feedback FOR SELECT USING (true);
CREATE POLICY "Service can insert recommendation_feedback"
  ON public.recommendation_feedback FOR INSERT WITH CHECK (true);
