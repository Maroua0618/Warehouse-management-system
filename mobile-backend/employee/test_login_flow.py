"""
Test the complete login flow to verify user data flows correctly.
This simulates what the Flutter app will do.
"""
import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

print("\n" + "="*60)
print("🧪 TESTING LOGIN FLOW - Employee to Dashboard")
print("="*60 + "\n")

# Create Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Test credentials
test_email = "employee@test.com"
test_password = "test123"  # Make sure this is the correct password

print(f"📧 Test User: {test_email}")
print(f"🔑 Password: {test_password}\n")

try:
    print("Step 1: Logging in with Supabase Auth...")
    print("-" * 60)
    
    # Login with Supabase (this is what the Flutter app does)
    response = supabase.auth.sign_in_with_password({
        "email": test_email,
        "password": test_password
    })
    
    if response.user:
        print(f"✅ Login Successful!")
        print(f"   User ID: {response.user.id}")
        print(f"   Email: {response.user.email}")
        print(f"   Session Token: {response.session.access_token[:50]}...\n")
        
        user_id = response.user.id
        email = response.user.email
        
        # Get user's name from the users table
        print("Step 2: Getting user profile from database...")
        print("-" * 60)
        
        user_data = supabase.table("users").select("*").eq("id", user_id).single().execute()
        
        if user_data.data:
            print(f"✅ User Profile Found:")
            print(f"   Name: {user_data.data.get('name')}")
            print(f"   Email: {user_data.data.get('email')}")
            print(f"   Role: {user_data.data.get('role')}")
            print(f"   Status: {user_data.data.get('status')}\n")
            
            # Get task statistics
            print("Step 3: Getting task statistics...")
            print("-" * 60)
            
            # Total tasks
            total = supabase.table("operation_tasks")\
                .select("id", count="exact")\
                .eq("assigned_to_user_id", user_id)\
                .execute()
            
            # Completed tasks
            completed = supabase.table("operation_tasks")\
                .select("id", count="exact")\
                .eq("assigned_to_user_id", user_id)\
                .eq("status", "DONE")\
                .execute()
            
            # In progress tasks
            in_progress = supabase.table("operation_tasks")\
                .select("id", count="exact")\
                .eq("assigned_to_user_id", user_id)\
                .eq("status", "IN_PROGRESS")\
                .execute()
            
            # Pending tasks
            pending = supabase.table("operation_tasks")\
                .select("id", count="exact")\
                .eq("assigned_to_user_id", user_id)\
                .eq("status", "PENDING")\
                .execute()
            
            total_count = total.count or 0
            completed_count = completed.count or 0
            in_progress_count = in_progress.count or 0
            pending_count = pending.count or 0
            completion_rate = (completed_count / total_count * 100) if total_count > 0 else 0
            
            print(f"✅ Task Statistics:")
            print(f"   Total Tasks: {total_count}")
            print(f"   Completed: {completed_count}")
            print(f"   In Progress: {in_progress_count}")
            print(f"   Pending: {pending_count}")
            print(f"   Completion Rate: {completion_rate:.1f}%\n")
            
            # Summary
            print("="*60)
            print("📱 EXPECTED DASHBOARD DISPLAY")
            print("="*60)
            print(f"\n👤 Welcome Card:")
            print(f"   Name: {user_data.data.get('name')}")
            print(f"   Email: {user_data.data.get('email')}")
            print(f"   Role: {user_data.data.get('role')}")
            print(f"\n📊 Performance Stats:")
            print(f"   Total Tasks: {total_count}")
            print(f"   Completed: {completed_count}")
            print(f"   In Progress: {in_progress_count}")
            print(f"   Completion Rate: {completion_rate:.1f}%")
            print("\n✅ All data ready for dashboard integration!")
            
        else:
            print("❌ User profile not found in users table")
            print("   Please check if the user exists in the database")
    else:
        print("❌ Login failed - No user returned")
        
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    print("\n💡 Troubleshooting:")
    print("   1. Check if user exists: SELECT * FROM users WHERE email = 'employee@test.com'")
    print("   2. Verify password is correct")
    print("   3. Check Supabase connection")
    print(f"   4. Ensure user ID has tasks assigned in operation_tasks table")

print("\n" + "="*60 + "\n")
