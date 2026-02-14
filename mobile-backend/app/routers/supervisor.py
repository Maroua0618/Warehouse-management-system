from fastapi import APIRouter, Depends, HTTPException, status, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.dashboard import DashboardStats, RecentActivity, OperationalIssueResponse, OperationalIssueCreate
from datetime import datetime, date
from typing import List, Optional
import uuid

router = APIRouter()

@router.get("/dashboard", response_model=DashboardStats)
async def get_dashboard_stats(supabase: Client = Depends(get_supabase)):
    import asyncio
    today = date.today().isoformat()
    
    # Optimize with single query using count operations
    # Use select with count="exact" but only fetch count, not data
    async def fetch_active_employees():
        try:
            result = supabase.table("users").select("id", count="exact").eq("role", "EMPLOYEE").eq("status", "ACTIVE").execute()
            print(f"DEBUG - Active employees query result: {result}")
            print(f"DEBUG - Result data: {result.data}")
            print(f"DEBUG - Result count: {result.count}")
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching active employees: {e}")
            return 0
    
    async def fetch_pending_violations():
        try:
            result = supabase.table("override_decisions").select("id", count="exact").eq("status", "PENDING").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching pending violations: {e}")
            return 0
    
    async def fetch_orders_today():
        try:
            result = supabase.table("orders").select("id", count="exact").gte("created_at", f"{today}T00:00:00").lte("created_at", f"{today}T23:59:59").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching orders today: {e}")
            return 0
    
    async def fetch_ai_overrides():
        try:
            result = supabase.table("override_decisions").select("id", count="exact").gte("created_at", f"{today}T00:00:00").lte("created_at", f"{today}T23:59:59").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching AI overrides: {e}")
            return 0
    
    # Execute all queries in parallel
    active_employees, pending_violations, orders_today, ai_overrides = await asyncio.gather(
        fetch_active_employees(),
        fetch_pending_violations(),
        fetch_orders_today(),
        fetch_ai_overrides()
    )
    
    # Mock data for performance metrics (can be enhanced later)
    saved_today_meters = 287.0
    performance_percentage = 89.0
    
    return DashboardStats(
        active_employees=active_employees,
        pending_violations=pending_violations,
        orders_today=orders_today,
        ai_overrides=ai_overrides,
        saved_today_meters=saved_today_meters,
        performance_percentage=performance_percentage
    )

@router.get("/recent-activity", response_model=List[RecentActivity])
async def get_recent_activity(
    limit: int = Query(10, ge=1, le=50),
    supabase: Client = Depends(get_supabase)
):
    # Get recent audit logs - optimized to only select needed fields
    logs_result = supabase.table("audit_logs").select("id,action_type,entity_type,entity_id,ts").order("ts", desc=True).limit(limit).execute()
    
    activities = []
    for log in logs_result.data:
        activity_type = "LOG"
        if log.get("action_type") == "MANUAL_OVERRIDE":
            activity_type = "MANUAL_OVERRIDE"
        elif log.get("action_type") == "CREATE" and log.get("entity_type") == "ORDER":
            activity_type = "BULK_RECEIPT"
        elif log.get("action_type") == "SYSTEM_NOTIFICATION":
            activity_type = "SYSTEM_NOTIFICATION"
        
        activities.append(RecentActivity(
            id=log["id"],
            type=activity_type,
            title=f"{log.get('action_type', 'ACTION')} - {log.get('entity_type', 'ENTITY')}",
            description=f"Entity ID: {log.get('entity_id', 'N/A')}",
            timestamp=log["ts"],
            status=None
        ))
    
    return activities

@router.get("/operational-issues", response_model=List[OperationalIssueResponse])
def get_operational_issues(
    status: Optional[str] = Query(None),
    priority: Optional[str] = Query(None),
    issue_type: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    supabase: Client = Depends(get_supabase)
):
    # Build query - note: Supabase doesn't have operational_issues table in the schema provided
    # Let's use override_decisions as a proxy since those represent supervisory decisions
    query = supabase.table("override_decisions").select("*")
    
    if status:
        query = query.eq("status", status)
    
    # Get results  
    result = query.order("created_at", desc=True).range(skip, skip + limit - 1).execute()
    
    # Transform override_decisions to OperationalIssueResponse format
    issues = []
    for item in result.data:
        issues.append(OperationalIssueResponse(
            id=item["id"],
            issue_type="OVERRIDE",
            priority="MEDIUM",
            employee_name="N/A",
            title=f"Override Decision - {item['status']}",
            description=item.get("justification", ""),
            status=item["status"],
            created_at=item["created_at"],
            resolved_at=item.get("updated_at")
        ))
    
    return issues

@router.post("/operational-issues", response_model=OperationalIssueResponse)
def create_operational_issue(
    issue_data: OperationalIssueCreate,
    supabase: Client = Depends(get_supabase)
):
    # Since there's no operational_issues table in Supabase schema,
    # we'll create an audit log entry instead
    new_id = str(uuid.uuid4())
    
    audit_entry = {
        "id": new_id,
        "action_type": "ISSUE_CREATED",
        "entity_type": issue_data.issue_type,
        "entity_id": new_id,
        "details": {
            "priority": issue_data.priority,
            "employee_name": issue_data.employee_name,
            "title": issue_data.title,
            "description": issue_data.description
        }
    }
    
    result = supabase.table("audit_logs").insert(audit_entry).execute()
    
    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create issue")
    
    return OperationalIssueResponse(
        id=new_id,
        issue_type=issue_data.issue_type,
        priority=issue_data.priority,
        employee_name=issue_data.employee_name,
        title=issue_data.title,
        description=issue_data.description,
        status="PENDING",
        created_at=datetime.utcnow(),
        resolved_at=None
    )

@router.put("/operational-issues/{issue_id}/review")
def review_operational_issue(
    issue_id: str,
    supabase: Client = Depends(get_supabase)
):
    # Update audit log entry
    result = supabase.table("audit_logs").update({
        "details": {"status": "RESOLVED", "resolved_at": datetime.utcnow().isoformat()}
    }).eq("id", issue_id).execute()
    
    if not result.data:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    return {"message": "Issue reviewed successfully"}

@router.put("/operational-issues/{issue_id}/dismiss")
def dismiss_operational_issue(
    issue_id: str,
    supabase: Client = Depends(get_supabase)
):
    # Update audit log entry
    result = supabase.table("audit_logs").update({
        "details": {"status": "DISMISSED"}
    }).eq("id", issue_id).execute()
    
    if not result.data:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    return {"message": "Issue dismissed successfully"}

@router.get("/debug/users")
def debug_users(supabase: Client = Depends(get_supabase)):
    """Debug endpoint to check all users in the database"""
    try:
        result = supabase.table("users").select("*").execute()
        print(f"DEBUG - All users: {result.data}")
        return {
            "count": len(result.data),
            "users": result.data
        }
    except Exception as e:
        print(f"Error fetching users: {e}")
        raise HTTPException(status_code=500, detail=str(e))
