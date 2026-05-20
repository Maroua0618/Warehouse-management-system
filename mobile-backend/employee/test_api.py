"""
Test API endpoints.

This script contains example requests to test the mobile backend API.
"""
import requests
import json

BASE_URL = "http://localhost:8000"


def test_health_check():
    """Test health check endpoint."""
    print("\n=== Testing Health Check ===")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.status_code == 200


def test_login(email: str = "employee1@example.com", password: str = "password123"):
    """Test login endpoint."""
    print("\n=== Testing Login ===")
    response = requests.post(
        f"{BASE_URL}/auth/login",
        json={
            "email": email,
            "password": password
        }
    )
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"User: {data['user']['name']}")
        print(f"Role: {data['user']['role']}")
        print(f"Token: {data['access_token'][:50]}...")
        return data['access_token']
    else:
        print(f"Error: {response.json()}")
        return None


def test_get_profile(token: str):
    """Test get employee profile."""
    print("\n=== Testing Get Profile ===")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/employee/profile", headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Employee: {data['profile']['name']}")
        print(f"Zone: {data['profile']['zone']}")
        print(f"Tasks Completed: {data['performance']['tasks_completed']}/{data['performance']['total_tasks']}")
        print(f"Accuracy: {data['performance']['accuracy']}%")
        print(f"Efficiency: {data['performance']['efficiency']}%")
    else:
        print(f"Error: {response.json()}")


def test_get_tasks(token: str):
    """Test get employee tasks."""
    print("\n=== Testing Get Tasks ===")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/tasks", headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Ingoing Tasks: {len(data['ingoing_tasks'])}")
        print(f"Outgoing Tasks: {len(data['outgoing_tasks'])}")
        
        if data['ingoing_tasks']:
            task = data['ingoing_tasks'][0]
            print(f"\nFirst Task:")
            print(f"  ID: {task['id']}")
            print(f"  Type: {task['order_type']}")
            print(f"  Status: {task['status']}")
            print(f"  Items: {task['item_count']}")
            return task['id']
    else:
        print(f"Error: {response.json()}")
    return None


def test_get_task_detail(token: str, task_id: str):
    """Test get task detail."""
    print(f"\n=== Testing Get Task Detail ===")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/tasks/{task_id}", headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Order: {data['order_code']}")
        print(f"Type: {data['order_type']}")
        print(f"Status: {data['status']}")
        print(f"Items: {len(data['items'])}")
        if data.get('route'):
            print(f"Route Distance: {data['route']['total_distance_meters']}m")
            print(f"Estimated Time: {data['route'].get('estimated_time_minutes', 'N/A')} mins")
        if data.get('chariot'):
            print(f"Chariot: {data['chariot']['code']}")
    else:
        print(f"Error: {response.json()}")


def test_get_issue_types(token: str):
    """Test get issue types."""
    print("\n=== Testing Get Issue Types ===")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/tasks/issues/types", headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Available Categories: {len(data['operational_categories'])}")
        for category in data['operational_categories']:
            print(f"  - {category['name']}: {category['description']}")
    else:
        print(f"Error: {response.json()}")


def run_all_tests():
    """Run all tests."""
    print("=" * 60)
    print("MobAI WMS - Mobile Backend API Tests")
    print("=" * 60)
    
    # Test health check
    if not test_health_check():
        print("\n❌ Health check failed. Is the server running?")
        return
    
    # Test login
    token = test_login()
    if not token:
        print("\n❌ Login failed. Check your database and credentials.")
        return
    
    print("\n✅ Authentication successful!")
    
    # Test profile
    test_get_profile(token)
    
    # Test tasks
    task_id = test_get_tasks(token)
    
    # Test task detail if we have a task
    if task_id:
        test_get_task_detail(token, task_id)
    
    # Test issue types
    test_get_issue_types(token)
    
    print("\n" + "=" * 60)
    print("Tests completed!")
    print("=" * 60)


if __name__ == "__main__":
    run_all_tests()
