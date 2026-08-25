import os
import json
import google.generativeai as genai
from typing import List, Optional

# Attempt to configure Gemini if key is provided
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

async def analyze_document_text(ocr_text: str) -> dict:
    gemini_key = os.getenv("GEMINI_API_KEY", "")
    if not gemini_key:
        print("Warning: No GEMINI_API_KEY provided. Falling back to mock.")
        return _mock_document_response(ocr_text)
    
    genai.configure(api_key=gemini_key)
        
    try:
        # We use gemini-3.6-flash to ensure maximum compatibility with the installed SDK
        model = genai.GenerativeModel('gemini-3.6-flash')
        
        system_prompt = """You are a highly accurate document analysis assistant for Malaysian government letters.
Your job is to read the OCR text provided and extract key facts into a precise JSON structure.
Follow these rules strictly:
1. Identify the document type and match it to one of these: ic_renewal_damaged, ic_renewal_address_change, ic_renewal_lost_first, ic_renewal_lost_second, ic_renewal_lost_third_plus, lhdn_notice_of_assessment, lhdn_notice_of_additional_assessment, lhdn_cp500, lhdn_audit_notice, roadtax_driving_license, traffic_summons, court_notice, epf_kwsp_letter, socso_perkeso_letter, electricity_tnb, or unknown.
2. Provide a plain language summary of the document's purpose (under 2 sentences).
3. Extract any specific deadline dates (return as string or null if not found).
4. Extract any required fee amounts (e.g. "RM 150.00" or null if none).
5. State the required action the user needs to take.
6. List any required items or documents the user must prepare (e.g., IC copy, Police Report).
7. SCAM DETECTION: Look for signs of a scam (e.g., extreme urgency + threats of arrest/freezing, requests for OTP/PINs, asking to transfer to a personal account or crypto, unofficial email domains). If a scam is suspected, set is_scam_suspected to true and provide reasons.
8. Extract any phone numbers or email addresses printed on the document into extracted_contacts.
9. You MUST return ONLY valid JSON matching the exact schema below. Do not include markdown formatting or backticks.

REQUIRED JSON SCHEMA:
{
  "document_type": "string (e.g. traffic_summons, lhdn_notice, ic_renewal_lost, unknown)",
  "issuing_agency": "string (e.g. JPJ, LHDN, PDRM)",
  "summary_plain_language": "string",
  "deadline_date": "string or null",
  "fee_amount": "string or null",
  "required_action": "string",
  "required_items": ["string"],
  "confidence": "string (high, medium, low)",
  "official_portal": "string (URL to official website if known, else https://www.malaysia.gov.my)",
  "last_verified": "2026-08-25",
  "is_rules_verified_stale": false,
  "is_scam_suspected": boolean,
  "scam_reasons": ["string"],
  "verification_hotline": "string or null",
  "verification_portal": "string or null",
  "extracted_contacts": ["string"]
}
"""
        
        prompt = f"{system_prompt}\n\nDOCUMENT OCR TEXT:\n{ocr_text}"
        response = model.generate_content(prompt)
        response_text = response.text.strip()
        
        # Remove markdown code blocks if the model wrapped the JSON
        if response_text.startswith("```json"):
            response_text = response_text[7:-3].strip()
        elif response_text.startswith("```"):
            response_text = response_text[3:-3].strip()
            
        return json.loads(response_text)
    except Exception as e:
        print(f"LLM Error: {e}")
        return _mock_document_response(ocr_text)

import base64

async def analyze_document_with_file(file_base64: str, mime_type: str) -> dict:
    gemini_key = os.getenv("GEMINI_API_KEY", "")
    if not gemini_key:
        print("Warning: No GEMINI_API_KEY provided. Falling back to mock.")
        return _mock_document_response("Unreadable Web File")
    
    genai.configure(api_key=gemini_key)
        
    try:
        model = genai.GenerativeModel('gemini-3.6-flash')
        
        system_prompt = """You are a highly accurate document analysis assistant for Malaysian government letters.
Your job is to visually read the document file provided and extract key facts into a precise JSON structure.
Follow these rules strictly:
1. Identify the document type and match it to one of these: ic_renewal_damaged, ic_renewal_address_change, ic_renewal_lost_first, ic_renewal_lost_second, ic_renewal_lost_third_plus, lhdn_notice_of_assessment, lhdn_notice_of_additional_assessment, lhdn_cp500, lhdn_audit_notice, roadtax_driving_license, traffic_summons, court_notice, epf_kwsp_letter, socso_perkeso_letter, electricity_tnb, or unknown.
2. Provide a plain language summary of the document's purpose (under 2 sentences).
3. Extract any specific deadline dates (return as string or null if not found).
4. Extract any required fee amounts (e.g. "RM 150.00" or null if none).
5. State the required action the user needs to take.
6. List any required items or documents the user must prepare (e.g., IC copy, Police Report).
7. SCAM DETECTION: Look for signs of a scam (e.g., extreme urgency + threats of arrest/freezing, requests for OTP/PINs, asking to transfer to a personal account or crypto, unofficial email domains). If a scam is suspected, set is_scam_suspected to true and provide reasons.
8. Extract any phone numbers or email addresses printed on the document into extracted_contacts.
9. You MUST return ONLY valid JSON matching the exact schema below. Do not include markdown formatting or backticks.

REQUIRED JSON SCHEMA:
{
  "document_type": "string (e.g. traffic_summons, lhdn_notice, ic_renewal_lost, unknown)",
  "issuing_agency": "string (e.g. JPJ, LHDN, PDRM)",
  "summary_plain_language": "string",
  "deadline_date": "string or null",
  "fee_amount": "string or null",
  "required_action": "string",
  "required_items": ["string"],
  "confidence": "string (high, medium, low)",
  "official_portal": "string (URL to official website if known, else https://www.malaysia.gov.my)",
  "last_verified": "2026-08-25",
  "is_rules_verified_stale": false,
  "is_scam_suspected": boolean,
  "scam_reasons": ["string"],
  "verification_hotline": "string or null",
  "verification_portal": "string or null",
  "extracted_contacts": ["string"]
}
"""
        file_data = base64.b64decode(file_base64)
        response = model.generate_content([
            system_prompt,
            {"mime_type": mime_type, "data": file_data}
        ])
        response_text = response.text.strip()
        
        if response_text.startswith("```json"):
            response_text = response_text[7:-3].strip()
        elif response_text.startswith("```"):
            response_text = response_text[3:-3].strip()
            
        return json.loads(response_text)
    except Exception as e:
        print(f"LLM Vision Error: {e}")
        return _mock_document_response("Unreadable Web File")


def _mock_document_response(text: str) -> dict:
    # A simple mock that matches the expected LlmResult JSON structure in Flutter
    return {
        "document_type": "lhdn_notice_of_assessment",
        "issuing_agency": "Lembaga Hasil Dalam Negeri (LHDN)",
        "summary_plain_language": "This is a Notice of Assessment (Borang J) from LHDN. It confirms your tax for the year has been assessed.",
        "deadline_date": "2026-11-15",
        "fee_amount": "RM 0.00",
        "required_action": "Log in to MyTax to view and pay any outstanding balance.",
        "required_items": ["IC Copy", "EA Form"],
        "confidence": "high",
        "official_portal": "https://mytax.hasil.gov.my",
        "last_verified": "2026-08-25",
        "is_rules_verified_stale": False,
        "is_scam_suspected": False,
        "scam_reasons": [],
        "verification_hotline": "03-89111000",
        "verification_portal": "https://mytax.hasil.gov.my",
        "extracted_contacts": []
    }
