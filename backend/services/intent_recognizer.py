import os
import google.generativeai as genai

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

async def recognize_intent(transcript: str, language: str) -> dict:
    transcript_upper = transcript.upper()
    
    # Simple Mock fallback for intents, similar to AppConstants.intentForTranscript
    target_screen = "home"
    confidence = 0.0
    action_type = "unknown"
    
    if "ROUTE" in transcript_upper or "BUS" in transcript_upper or "WALK" in transcript_upper:
        target_screen = "tropicalRoute"
        confidence = 0.9
        action_type = "mobility"
    elif "CHECK" in transcript_upper or "DOCUMENT" in transcript_upper or "BRING" in transcript_upper:
        target_screen = "documentChecker"
        confidence = 0.9
        action_type = "public_service"
    elif "LETTER" in transcript_upper or "EXPLAIN" in transcript_upper or "MEAN" in transcript_upper:
        target_screen = "letterInterpreter"
        confidence = 0.9
        action_type = "public_service"
        
    return {
        "targetScreen": target_screen,
        "confidence": confidence,
        "actionType": action_type,
        "extractedEntities": {},
        "rawTranscript": transcript
    }
