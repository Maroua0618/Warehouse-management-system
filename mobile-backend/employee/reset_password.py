"""
Reset password for the test user
"""
import os
import requests
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

print("\n" + "="*60)
print("🔐 RESETTING USER PASSWORD")
print("="*60 + "\n")

email = "employee@test.com"
new_password = "test123"

# First, get the user ID
supabase: Client = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

try:
    # List users to find our user
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    }
    
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        users = response.json().get("users", [])
        target_user = None
        
        for user in users:
            if user.get("email") == email:
                target_user = user
                break
        
        if target_user:
            user_id = target_user["id"]
            print(f"✅ Found user: {email}")
            print(f"   User ID: {user_id}\n")
            
            # Update password
            update_url = f"{SUPABASE_URL}/auth/v1/admin/users/{user_id}"
            update_payload = {
                "password": new_password
            }
            
            update_response = requests.put(
                update_url,
                json=update_payload,
                headers={
                    **headers,
                    "Content-Type": "application/json"
                }
            )
            
            if update_response.status_code == 200:
                print(f"✅ Password reset successfully!")
                print(f"   Email: {email}")
                print(f"   New Password: {new_password}")
                print(f"\n🧪 You can now test login with these credentials")
            else:
                print(f"❌ Failed to reset password")
                print(f"   Status: {update_response.status_code}")
                print(f"   Response: {update_response.text}")
        else:
            print(f"❌ User not found: {email}")
            print("\n💡 Available users:")
            for user in users[:5]:  # Show first 5 users
                print(f"   - {user.get('email')} (ID: {user.get('id')})")
    else:
        print(f"❌ Failed to list users")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        
except Exception as e:
    print(f"❌ Error: {str(e)}")

print("\n" + "="*60 + "\n")
