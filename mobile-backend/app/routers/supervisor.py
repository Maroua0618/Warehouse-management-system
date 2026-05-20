"""
Supervisor Dashboard Router - Dashboard stats, recent activity, operational issues
Uses existing tables: users, orders, operation_tasks, override_decisions, ai_recommendations, audit_logs
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.dashboard import (
    DashboardStats,
    RecentActivity,
    OperationalIssueResponse,
    OperationalIssueCreate,
)
from datetime import datetime, date, timedelta
from typing import List, Optional
import uuid

router = APIRouter()


@router.get("/dashboard", response_model=DashboardStats)
async def get_dashboard_stats(supabase: Client = Depends(get_supabase)):
    """Get supervisor dashboard statistics"""
    import asyncio
    today = date.today().isoformat()
    
    async def fetch_active_employees():
        """Count active employees from users table (EMPLOYEE role only)"""
        try:
            # Get active employees (status='ACTIVE' and role='EMPLOYEE')
            result = supabase.table("users").select(
                "id", count="exact"
            ).eq("status", "ACTIVE").eq("role", "EMPLOYEE").execute()
            
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching active employees: {e}")
            return 0
    
    async def fetch_pending_violations():
        """Count pending override decisions"""
        try:
            result = supabase.table("override_decisions").select(
                "id", count="exact"
            ).eq("status", "PENDING").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching pending violations: {e}")
            return 0
    
    async def fetch_orders_today():
        """Count orders created today"""
        try:
            result = supabase.table("orders").select(
                "id", count="exact"
            ).gte("created_at", f"{today}T00:00:00").lte("created_at", f"{today}T23:59:59").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching orders today: {e}")
            return 0
    
    async def fetch_ai_overrides():
        """Count AI overrides today"""
        try:
            result = supabase.table("override_decisions").select(
                "id", count="exact"
            ).gte("created_at", f"{today}T00:00:00").lte("created_at", f"{today}T23:59:59").execute()
            return result.count if result.count is not None else 0
        except Exception as e:
            print(f"Error fetching AI overrides: {e}")
            return 0
    
    async def fetch_saved_distance():
        """Calculate distance saved from AI recommendations today"""
        try:
            result = supabase.table("ai_recommendations").select(
                "payload_json"
            ).in_("type", ["STORAGE_OPTIMIZATION", "PICKING_ROUTE_OPTIMIZATION"]).gte(
                "created_at", f"{today}T00:00:00"
            ).execute()
            
            total_saved = 0.0
            for rec in result.data if result.data else []:
                payload = rec.get("payload_json", {})
                # Calculate savings (mock - in real scenario, compare AI vs baseline)
                distance = payload.get("distance_meters", 0)
                # Assume 20% savings on average
                saved = distance * 0.2
                total_saved += saved
            
            return total_saved
        except Exception as e:
            print(f"Error fetching saved distance: {e}")
            return 0.0
    
    async def fetch_performance():
        """Calculate overall performance percentage"""
        try:
            # Get completed vs total tasks today
            completed_result = supabase.table("operation_tasks").select(
                "id", count="exact"
            ).eq("status", "COMPLETED").gte("completed_at", f"{today}T00:00:00").execute()
            
            total_result = supabase.table("operation_tasks").select(
                "id", count="exact"
            ).gte("created_at", f"{today}T00:00:00").execute()
            
            completed = completed_result.count if completed_result.count else 0
            total = total_result.count if total_result.count else 0
            
            if total > 0:
                return (completed / total) * 100
            return 0.0
        except Exception as e:
            print(f"Error fetching performance: {e}")
            return 0.0
    
    # Execute all queries in parallel
    (
        active_employees,
        pending_violations,
        orders_today,
        ai_overrides,
        saved_distance,
        performance,
    ) = await asyncio.gather(
        fetch_active_employees(),
        fetch_pending_violations(),
        fetch_orders_today(),
        fetch_ai_overrides(),
        fetch_saved_distance(),
        fetch_performance(),
    )
    
    return DashboardStats(
        active_employees=active_employees,
        pending_violations=pending_violations,
        orders_today=orders_today,
        ai_overrides=ai_overrides,
        saved_today_meters=saved_distance,
        performance_percentage=performance,
    )


@router.get("/recent-activity", response_model=List[RecentActivity])
async def get_recent_activity(
    limit: int = Query(10, ge=1, le=50),
    supabase: Client = Depends(get_supabase),
):
    """Get recent activity from audit logs"""
    try:
        # Get recent audit logs
        logs_result = supabase.table("audit_logs").select(
            "id, action_type, entity_type, entity_id, ts, actor_user_id"
        ).order("ts", desc=True).limit(limit).execute()
        
        activities = []
        for log in logs_result.data:
            action_type = log.get("action_type", "ACTION")
            entity_type = log.get("entity_type", "ENTITY")
            
            # Determine activity type and title
            if action_type == "OVERRIDE":
                activity_type = "MANUAL_OVERRIDE"
                title = f"AI Recommendation Overridden"
                description = f"Entity {entity_type}: {log.get('entity_id', 'N/A')}"
            elif action_type == "CREATE" and entity_type == "orders":
                activity_type = "BULK_RECEIPT"
                title = "New Order Created"
                description = f"Order ID: {log.get('entity_id', 'N/A')}"
            elif action_type == "ALERT":
                activity_type = "SYSTEM_NOTIFICATION"
                title = "System Alert"
                description = f"Alert for {entity_type}"
            else:
                activity_type = "LOG"
                title = f"{action_type} - {entity_type}"
                description = f"Entity ID: {log.get('entity_id', 'N/A')}"
            
            activities.append(
                RecentActivity(
                    id=log["id"],
                    type=activity_type,
                    title=title,
                    description=description,
                    timestamp=log["ts"],
                    status=None,
                )
            )
        
        return activities
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching recent activity: {str(e)}"
        )


@router.get("/operational-issues", response_model=List[OperationalIssueResponse])
def get_operational_issues(
    status: Optional[str] = Query(None),
    priority: Optional[str] = Query(None),
    issue_type: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),    supabase: Client = Depends(get_supabase),
):
    """Get operational issues (from AI alerts and override decisions)"""
    issues = []
    
    # Get alerts from ai_recommendations (ALERT_* types)
    try:
        alerts_result = supabase.table("ai_recommendations").select(
            "*"
        ).like("type", "ALERT_%").order("created_at", desc=True).limit(50).execute()
        
        for alert in alerts_result.data if alerts_result.data else []:
            payload = alert.get("payload_json", {})
            alert_type = alert["type"].replace("ALERT_", "")
            severity = payload.get("severity", "MEDIUM")
            is_resolved = payload.get("resolved", False)
            
            if status and (status == "RESOLVED" and not is_resolved):
                continue
            if status and (status == "PENDING" and is_resolved):
                continue
            if priority and severity != priority:
                continue
            if issue_type and alert_type != issue_type:
                continue
            
            issues.append(
                OperationalIssueResponse(
                    id=alert["id"],
                    issue_type=alert_type,
                    priority=severity,
                    employee_name=payload.get("employee_name", "N/A"),
                    title=payload.get("message", f"Alert: {alert_type}"),
                    description=payload.get("details", ""),
                    status="RESOLVED" if is_resolved else "PENDING",
                    created_at=alert["created_at"],
                    resolved_at=payload.get("resolved_at"),
                )
            )
    except Exception as e:
        print(f"Error fetching alerts: {e}")
        # Continue even if alerts fail
    
    # Get override decisions as issues
    try:
        overrides_result = supabase.table("override_decisions").select(
            "*"
        ).order("created_at", desc=True).limit(50).execute()
        
        for override in overrides_result.data if overrides_result.data else []:
            if status and override["status"] != status:
                continue
            if issue_type and issue_type != "OVERRIDE":
                continue
            
            # Get employee name from overridden_by_user_id if available
            employee_name = "N/A"
            if override.get("overridden_by_user_id"):
                try:
                    user_result = supabase.table("users").select("name").eq(
                        "id", override["overridden_by_user_id"]
                    ).single().execute()
                    if user_result.data:
                        employee_name = user_result.data.get("name", "N/A")
                except:
                    pass
            
            issues.append(
                OperationalIssueResponse(
                    id=override["id"],
                    issue_type="OVERRIDE",
                    priority="MEDIUM",
                    employee_name=employee_name,
                    title=f"AI Override: {override['status']}",
                    description=override.get("justification", ""),
                    status=override["status"],
                    created_at=override["created_at"],
                    resolved_at=override.get("updated_at"),
                )
            )
    except Exception as e:
        print(f"Error fetching overrides: {e}")
        # Continue even if overrides fail
    
    # Apply skip/limit
    issues = issues[skip : skip + limit]
    
    return issues


@router.post("/operational-issues", response_model=OperationalIssueResponse)
def create_operational_issue(
    issue_data: OperationalIssueCreate,
    supabase: Client = Depends(get_supabase),
):
    """Create a manual operational issue (saved as AI alert)"""
    try:
        issue_id = str(uuid.uuid4())
        
        # Create as AI recommendation with ALERT_MANUAL type
        alert_payload = {
            "severity": issue_data.priority,
            "employee_name": issue_data.employee_name,
            "message": issue_data.title,
            "details": issue_data.description,
            "resolved": False,
        }
        
        new_alert = {
            "id": issue_id,
            "type": f"ALERT_{issue_data.issue_type}",
            "payload_json": alert_payload,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        result = supabase.table("ai_recommendations").insert(new_alert).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to create issue")
        
        # Log to audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "action_type": "ISSUE_CREATED",
            "entity_type": "ai_recommendations",
            "entity_id": issue_id,
            "details": alert_payload,
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()
        
        return OperationalIssueResponse(
            id=issue_id,
            issue_type=issue_data.issue_type,
            priority=issue_data.priority,
            employee_name=issue_data.employee_name,
            title=issue_data.title,
            description=issue_data.description,
            status="PENDING",
            created_at=datetime.utcnow(),
            resolved_at=None,
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating operational issue: {str(e)}"
        )


@router.put("/operational-issues/{issue_id}/review")
def review_operational_issue(
    issue_id: str,
    user_id: str = Query(..., description="User reviewing the issue"),
    supabase: Client = Depends(get_supabase),
):
    """Review and resolve an operational issue"""
    try:
        # Update ai_recommendation payload
        result = supabase.table("ai_recommendations").select("*").eq("id", issue_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Issue not found")
        
        rec = result.data[0]
        payload = rec.get("payload_json", {})
        payload["resolved"] = True
        payload["resolved_at"] = datetime.utcnow().isoformat()
        payload["resolved_by_user_id"] = user_id
        
        supabase.table("ai_recommendations").update({"payload_json": payload}).eq(
            "id", issue_id
        ).execute()
        
        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "RESOLVE",
            "entity_type": "ai_recommendations",
            "entity_id": issue_id,
            "details": {"action": "REVIEWED"},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()
        
        return {"success": True, "message": "Issue reviewed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error reviewing issue: {str(e)}"
        )


@router.put("/operational-issues/{issue_id}/dismiss")
def dismiss_operational_issue(
    issue_id: str,
    user_id: str = Query(..., description="User dismissing the issue"),
    supabase: Client = Depends(get_supabase),
):
    """Dismiss an operational issue"""
    try:
        # Update ai_recommendation payload
        result = supabase.table("ai_recommendations").select("*").eq("id", issue_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Issue not found")
        
        rec = result.data[0]
        payload = rec.get("payload_json", {})
        payload["dismissed"] = True
        payload["dismissed_at"] = datetime.utcnow().isoformat()
        payload["dismissed_by_user_id"] = user_id
        
        supabase.table("ai_recommendations").update({"payload_json": payload}).eq(
            "id", issue_id
        ).execute()
        
        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "DISMISS",
            "entity_type": "ai_recommendations",
            "entity_id": issue_id,
            "details": {"action": "DISMISSED"},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()
        
        return {"success": True, "message": "Issue dismissed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error dismissing issue: {str(e)}"
        )
