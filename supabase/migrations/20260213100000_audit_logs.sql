-- ═══════════════════════════════════════════════════════
--  AUDIT LOGS TABLE
--  Immutable append-only log for all state changes
-- ═══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  ts            timestamptz DEFAULT now() NOT NULL,
  actor_user_id uuid REFERENCES public.users(id) ON DELETE SET NULL,
  action_type   text NOT NULL,
  entity_type   text NOT NULL,
  entity_id     text NOT NULL,
  details       jsonb DEFAULT '{}'::jsonb NOT NULL
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_audit_logs_ts     ON public.audit_logs (ts DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor  ON public.audit_logs (actor_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs (action_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_gin    ON public.audit_logs USING gin (details);

-- RLS: read-only for clients, insert via service role, no update/delete (immutable)
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read audit logs"
  ON public.audit_logs FOR SELECT USING (true);

CREATE POLICY "Service can insert audit logs"
  ON public.audit_logs FOR INSERT WITH CHECK (true);
