import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY")



if SUPABASE_URL == "https://your-project-ref.supabase.co" or SUPABASE_KEY == "your-anon-public-key-here":
    raise ValueError(
        "\n\n⚠️  PLEASE UPDATE .env WITH REAL CREDENTIALS ⚠️\n\n"
        "The .env file still contains placeholder values.\n"
        "Replace them with your actual Supabase URL and key.\n"
    )

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_supabase() -> Client:
    """Dependency to get Supabase client"""
    return supabase
