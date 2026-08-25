from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.document_analyzer import analyze_document_text
from services.intent_recognizer import recognize_intent

router = APIRouter()

from typing import Optional

class DocumentRequest(BaseModel):
    ocr_text: Optional[str] = None
    file_base64: Optional[str] = None
    mime_type: Optional[str] = None

class IntentRequest(BaseModel):
    transcript: str
    language: str = "en"

@router.post("/analyze-document")
async def analyze_document(request: DocumentRequest):
    try:
        if request.file_base64 and request.mime_type:
            from services.document_analyzer import analyze_document_with_file
            result = await analyze_document_with_file(request.file_base64, request.mime_type)
            return result
        else:
            result = await analyze_document_text(request.ocr_text or "")
            return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/intent")
async def intent_recognition(request: IntentRequest):
    try:
        result = await recognize_intent(request.transcript, request.language)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
