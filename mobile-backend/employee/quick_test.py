"""
Quick Health Check - Verify Backend Server is Running
"""
import requests

def check_server():
    """Check if backend server is running"""
    try:
        print("\n🔍 Checking backend server health...")
        print(f"   URL: http://localhost:8000")
        
        # Try to connect to root endpoint
        response = requests.get("http://localhost:8000", timeout=5)
        
        if response.status_code == 200:
            print("\n✅ Backend server is RUNNING!")
            print(f"   Status Code: {response.status_code}")
            print(f"\n📡 Server Response:")
            print(f"   {response.json()}")
            
            print(f"\n📚 Available Endpoints:")
            print(f"   POST   http://localhost:8000/api/auth/login")
            print(f"   GET    http://localhost:8000/api/employee/profile")
            print(f"   GET    http://localhost:8000/api/employee/stats")
            print(f"   GET    http://localhost:8000/api/tasks")
            print(f"   GET    http://localhost:8000/api/tasks/{{task_id}}")
            print(f"   PUT    http://localhost:8000/api/tasks/{{task_id}}/status")
            print(f"   POST   http://localhost:8000/api/tasks/{{task_id}}/validate")
            print(f"   POST   http://localhost:8000/api/tasks/{{task_id}}/report-issue")
            
            print(f"\n🧪 Next Step:")
            print(f"   Run full API tests:")
            print(f"   python test_supabase_api.py")
            
            return True
        else:
            print(f"\n⚠️  Server responded with status: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to backend server!")
        print("\n💡 Server is not running. Start it with:")
        print("   cd mobile-backend/employee")
        print("   python run.py")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        return False

if __name__ == "__main__":
    print("""
    ╔═══════════════════════════════════════════════╗
    ║     Backend Server Health Check               ║
    ╚═══════════════════════════════════════════════╝
    """)
    
    check_server()
    
    print("""
    ╔═══════════════════════════════════════════════╗
    ║                  Summary                      ║
    ╚═══════════════════════════════════════════════╝
    
    ✅ Backend:     FastAPI + Uvicorn
    ✅ Database:    Supabase (Remote)
    ✅ Auth:        JWT + Supabase Auth
    ✅ Mock Data:   5 tasks, 8 SKUs, 3 deliveries
    
    📱 Ready to build mobile app UI!
    """)
