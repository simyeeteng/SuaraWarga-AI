from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import os
from supabase import create_client, Client

router = APIRouter()

def get_supabase() -> Client:
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        raise HTTPException(status_code=500, detail="Supabase credentials not found.")
    return create_client(url, key)

class ChecklistCreateRequest(BaseModel):
    document_type: str
    title: str
    items: List[str]

@router.post("/from-document")
async def create_checklist_from_document(req: ChecklistCreateRequest):
    supabase = get_supabase()
    
    # 1. Insert the Checklist
    res = supabase.table("checklists").insert({
        "document_type": req.document_type,
        "title": req.title
    }).execute()
    
    if not res.data:
        raise HTTPException(status_code=500, detail="Failed to create checklist")
    
    checklist_id = res.data[0]["id"]
    
    # 2. Insert the Checklist Items
    items_to_insert = []
    for task in req.items:
        items_to_insert.append({
            "checklist_id": checklist_id,
            "task": task
        })
        
    if items_to_insert:
        supabase.table("checklist_items").insert(items_to_insert).execute()
        
    return {"status": "success", "checklist_id": checklist_id}
