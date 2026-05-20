"""
Operational Monitor Router - Employee tracking and operational alerts
Uses existing tables: users, operation_tasks, ai_recommendations (type='ALERT_*'), audit_logs
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.operational_monitor import (
    EmployeeTrackingResponse,
    OperationalAlertResponse,
)
from typing import List, Optional
from datetime import datetime, timedelta
import uuid

router = APIRouter()


@router.get("/operational-monitor/employees", response_model=List[EmployeeTrackingResponse])
async def get_employee_tracking(
    active_only: bool = Query(True),
    supabase: Client = Depends(get_supabase),
):
    """Get real-time employee activity and performance"""
    try:
        # Get all employees
        query = supabase.table("users").select("*")
        
        if active_only:
            # Filter employees with recent activity (last 24 hours)
            cutoff_time = (datetime.utcnow() - timedelta(hours=24)).isoformat()
            # We'll filter after fetching based on last_activity
        
        result = query.execute()
        
        employee_tracking = []
        for user in result.data:
            user_id = user["id"]
            
            # Get active tasks
            active_tasks_result = supabase.table("operation_tasks").select(
                "id, operation_type, status"
            ).eq("assigned_to_user_id", user_id).in_("status", ["PENDING", "IN_PROGRESS"]).execute()
            
            active_tasks = active_tasks_result.data if active_tasks_result.data else []
            
            # Get completed tasks today
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
            completed_tasks_result = supabase.table("operation_tasks").select(
                "id, completed_at"
            ).eq("assigned_to_user_id", user_id).eq("status", "COMPLETED").gte(
                "completed_at", today_start
            ).execute()
            
            completed_count = len(completed_tasks_result.data) if completed_tasks_result.data else 0
            
            # Get last activity from audit_logs
            last_activity_result = supabase.table("audit_logs").select(
                "ts"
            ).eq("actor_user_id", user_id).order("ts", desc=True).limit(1).execute()
            
            last_activity = None
            if last_activity_result.data:
                last_activity = last_activity_result.data[0]["ts"]
            
            # Calculate performance metrics (simplified)
            # In real implementation, calculate from AI metrics or detailed performance tables
            performance_percentage = 85.0 + (completed_count * 2.5)  # Mock calculation
            if performance_percentage > 100:
                performance_percentage = 100.0
            
            # Determine current activity
            current_activity = "IDLE"
            if active_tasks:
                current_activity = active_tasks[0]["operation_type"]
            
            # Check if active (has activity in last 4 hours)
            is_active = False
            if last_activity:
                last_activity_dt = datetime.fromisoformat(last_activity.replace('Z', '+00:00'))
                is_active = (datetime.utcnow().replace(tzinfo=last_activity_dt.tzinfo) - last_activity_dt).total_seconds() < 14400
            
            # Skip inactive employees if active_only
            if active_only and not is_active:
                continue
            
            employee_tracking.append({
                "employee_id": user_id,
                "employee_name": user.get("name"),
                "role": user.get("role", "OPERATOR"),
                "current_activity": current_activity,
                "active_task_count": len(active_tasks),
                "completed_tasks_today": completed_count,
                "performance_percentage": performance_percentage,
                "last_activity_at": last_activity,
            })
        
        return employee_tracking
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching employee tracking: {str(e)}"
        )


@router.get("/operational-monitor/employees/{employee_id}", response_model=EmployeeTrackingResponse)
async def get_employee_details(
    employee_id: str,
    supabase: Client = Depends(get_supabase),
):
    """Get detailed tracking for a specific employee"""
    try:
        # Get employee
        user_result = supabase.table("users").select("*").eq("id", employee_id).execute()
        
        if not user_result.data:
            raise HTTPException(status_code=404, detail="Employee not found")
        
        user = user_result.data[0]
        
        # Get active tasks
        active_tasks_result = supabase.table("operation_tasks").select(
            "*, order:orders!operation_tasks_order_id_fkey(source)"
        ).eq("assigned_to_user_id", employee_id).in_("status", ["PENDING", "IN_PROGRESS"]).execute()
        
        active_tasks = []
        for task in active_tasks_result.data if active_tasks_result.data else []:
            order = task.get("order", {})
            active_tasks.append({
                "task_id": task["id"],
                "operation_type": task["operation_type"],
                "status": task["status"],
                "order_code": order.get("source"),
                "created_at": task["created_at"],
            })
        
        # Get completed tasks today
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
        completed_tasks_result = supabase.table("operation_tasks").select(
            "id"
        ).eq("assigned_to_user_id", employee_id).eq("status", "COMPLETED").gte(
            "completed_at", today_start
        ).execute()
        
        completed_count = len(completed_tasks_result.data) if completed_tasks_result.data else 0
        
        # Get last activity
        last_activity_result = supabase.table("audit_logs").select(
            "ts, action_type, entity_type"
        ).eq("actor_user_id", employee_id).order("ts", desc=True).limit(1).execute()
        
        last_activity = None
        if last_activity_result.data:
            last_activity = last_activity_result.data[0]["ts"]
        
        # Calculate performance
        performance_percentage = 85.0 + (completed_count * 2.5)
        if performance_percentage > 100:
            performance_percentage = 100.0
        
        # Current activity
        current_activity = "IDLE"
        if active_tasks:
            current_activity = active_tasks[0]["operation_type"]
        
        return {
            "employee_id": employee_id,
            "employee_name": user.get("name"),
            "role": user.get("role", "OPERATOR"),
            "current_activity": current_activity,
            "active_task_count": len(active_tasks),
            "completed_tasks_today": completed_count,
            "performance_percentage": performance_percentage,
            "last_activity_at": last_activity,
            "active_tasks": active_tasks,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching employee details: {str(e)}"
        )


@router.get("/operational-monitor/alerts", response_model=List[OperationalAlertResponse])
async def get_operational_alerts(
    severity: Optional[str] = Query(None),
    active_only: bool = Query(True),
    supabase: Client = Depends(get_supabase),
):
    """Get operational alerts (delays, issues, anomalies)"""
    try:
        # Query ai_recommendations where type starts with 'ALERT_'
        query = supabase.table("ai_recommendations").select("*").like("type", "ALERT_%")
        
        if active_only:
            # Filter alerts from last 24 hours
            cutoff_time = (datetime.utcnow() - timedelta(hours=24)).isoformat()
            query = query.gte("created_at", cutoff_time)
        
        result = query.order("created_at", desc=True).execute()
        
        alerts = []
        for rec in result.data:
            payload = rec.get("payload_json", {})
            
            alert_severity = payload.get("severity", "INFO")
            
            # Filter by severity if specified
            if severity and alert_severity != severity:
                continue
            
            # Determine if resolved (based on payload or separate field)
            is_resolved = payload.get("resolved", False)
            if active_only and is_resolved:
                continue
            
            alerts.append({
                "id": rec["id"],
                "alert_type": rec["type"],
                "severity": alert_severity,
                "message": payload.get("message", "Operational alert"),
                "entity_type": payload.get("entity_type"),
                "entity_id": payload.get("entity_id"),
                "details": payload,
                "is_resolved": is_resolved,
                "created_at": rec["created_at"],
            })
        
        return alerts
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching operational alerts: {str(e)}"
        )


@router.post("/operational-monitor/alerts/{alert_id}/resolve")
async def resolve_alert(
    alert_id: str,
    user_id: str = Query(..., description="User resolving the alert"),
    resolution_notes: Optional[str] = Query(None),
    supabase: Client = Depends(get_supabase),
):
    """Mark an alert as resolved"""
    try:
        # Get current recommendation
        result = supabase.table("ai_recommendations").select("*").eq("id", alert_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Alert not found")
        
        rec = result.data[0]
        payload = rec.get("payload_json", {})
        
        # Update payload with resolution info
        payload["resolved"] = True
        payload["resolved_at"] = datetime.utcnow().isoformat()
        payload["resolved_by_user_id"] = user_id
        payload["resolution_notes"] = resolution_notes
        
        # Update recommendation
        supabase.table("ai_recommendations").update({
            "payload_json": payload
        }).eq("id", alert_id).execute()
        
        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "RESOLVE",
            "entity_type": "ai_recommendations",
            "entity_id": alert_id,
            "details": {"resolution_notes": resolution_notes},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()
        
        return {
            "success": True,
            "message": "Alert resolved successfully",
            "alert_id": alert_id,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error resolving alert: {str(e)}"
        )


@router.get("/operational-monitor/performance-summary")
async def get_performance_summary(
    supabase: Client = Depends(get_supabase),
):
    """Get overall warehouse performance summary"""
    try:
        # Get today's task completion stats
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
        
        # Completed tasks today
        completed_result = supabase.table("operation_tasks").select(
            "id, operation_type"
        ).eq("status", "COMPLETED").gte("completed_at", today_start).execute()
        
        completed_tasks = completed_result.data if completed_result.data else []
        
        # Pending tasks
        pending_result = supabase.table("operation_tasks").select(
            "id"
        ).eq("status", "PENDING").execute()
        
        pending_count = len(pending_result.data) if pending_result.data else 0
        
        # Active employees
        active_employees_result = supabase.table("operation_tasks").select(
            "assigned_to_user_id"
        ).in_("status", ["PENDING", "IN_PROGRESS"]).execute()
        
        active_employee_ids = set()
        if active_employees_result.data:
            active_employee_ids = set([t["assigned_to_user_id"] for t in active_employees_result.data if t.get("assigned_to_user_id")])
        
        # Active alerts
        cutoff_time = (datetime.utcnow() - timedelta(hours=24)).isoformat()
        alerts_result = supabase.table("ai_recommendations").select(
            "id"
        ).like("type", "ALERT_%").gte("created_at", cutoff_time).execute()
        
        alert_count = len(alerts_result.data) if alerts_result.data else 0
        
        # Calculate metrics by operation type
        storage_completed = len([t for t in completed_tasks if t.get("operation_type") == "STORAGE"])
        picking_completed = len([t for t in completed_tasks if t.get("operation_type") == "PICKING"])
        
        return {
            "date": datetime.utcnow().date().isoformat(),
            "completed_tasks_today": len(completed_tasks),
            "pending_tasks": pending_count,
            "active_employees": len(active_employee_ids),
            "active_alerts": alert_count,
            "tasks_by_type": {
                "STORAGE": storage_completed,
                "PICKING": picking_completed,
            },
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching performance summary: {str(e)}"
        )
