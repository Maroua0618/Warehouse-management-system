"""
Create auth user in Supabase for testing.
This uses the Admin API to create a user directly.
"""
import os
import requests
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

print("\n" + "="*60)
print("🔐 CREATING AUTH USER IN SUPABASE")
print("="*60 + "\n")

# User details
user_id = "30c64ceb-a1f3-43b9-8407-d6ceacbca7a8"
email = "employee@test.com"
password = "test123"
name = "Alex Johnson"

print(f"Creating user:")
print(f"  Email: {email}")
print(f"  Password: {password}")
print(f"  ID: {user_id}")
print(f"  Name: {name}\n")

# Create user using Supabase Admin API
url = f"{SUPABASE_URL}/auth/v1/admin/users"
headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

payload = {
    "email": email,
    "password": password,
    "email_confirm": True,  # Auto-confirm email
    "user_metadata": {
        "name": name
    },
    "app_metadata": {
        "provider": "email"
    }
}

# If you want to use specific UUID
# payload["id"] = user_id

try:
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code in [200, 201]:
        data = response.json()
        created_user_id = data.get("id")
        print("✅ User created successfully!")
        print(f"   User ID: {created_user_id}")
        print(f"   Email: {data.get('email')}")
        print(f"   Email Confirmed: {data.get('email_confirmed_at') is not None}")
        
        # Now update the users table to use this ID
        print(f"\n📝 To link with your database user, run this SQL in Supabase:")
        print(f"\nUPDATE public.users")
        print(f"SET id = '{created_user_id}'")
        print(f"WHERE email = '{email}';")
        print(f"\nUPDATE public.operation_tasks")
        print(f"SET assigned_to_user_id = '{created_user_id}'")
        print(f"WHERE assigned_to_user_id = '{user_id}';")
        
    elif response.status_code == 422:
        error = response.json()
        if "already been registered" in str(error):
            print("⚠️  User already exists!")
            print("   You can reset the password in Supabase Dashboard")
            print("   Or delete the user and run this script again")
        else:
            print(f"❌ Error: {error}")
    else:
        print(f"❌ Failed to create user")
        print(f"   Status Code: {response.status_code}")
        print(f"   Response: {response.text}")
        
except Exception as e:
    print(f"❌ Error: {str(e)}")

print("\n" + "="*60)
print("🧪 Next step: Run test_login_flow.py to verify")
print("="*60 + "\n")
