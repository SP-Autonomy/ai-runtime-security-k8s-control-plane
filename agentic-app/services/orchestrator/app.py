from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import requests
import uuid

AIRS_BASE_URL = os.getenv("AIRS_BASE_URL", "http://airs-cp-gateway.ai-security.svc.cluster.local:8080")
TOOLS_BASE_URL = os.getenv("TOOLS_BASE_URL", "http://tools.ai-tools.svc.cluster.local:9000")

MODEL = os.getenv("MODEL", "llama3.2:1b")

app = FastAPI(title="Agentic Orchestrator", version="0.1.0")

class ChatReq(BaseModel):
    message: str
    user_id: str | None = None
    customer_id: str | None = None

def call_llm_via_airs(messages, user_id=None):
    payload = {
        "model": MODEL,
        "messages": messages,
        "stream": False,
        "user": user_id
    }
    r = requests.post(f"{AIRS_BASE_URL}/v1/chat/completions", json=payload, timeout=120)
    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=r.text)
    return r.json()

@app.get("/health")
def health():
    return {"status": "ok", "airs": AIRS_BASE_URL, "tools": TOOLS_BASE_URL}

@app.post("/chat")
def chat(req: ChatReq):
    session_id = str(uuid.uuid4())
    user_id = req.user_id or "demo-user"

    # 1) Basic "agentic" planning: decide whether to call tools
    messages = [{"role": "system", "content": "You are a helpful support agent. Use tools only when needed."}]
    messages.append({"role": "user", "content": req.message})

    tool_context = ""

    # If customer_id present, fetch customer record (PII present for demo)
    if req.customer_id:
        cr = requests.get(f"{TOOLS_BASE_URL}/customer/{req.customer_id}", timeout=30)
        if cr.status_code != 200:
            raise HTTPException(status_code=502, detail=f"tools error: {cr.text}")
        tool_context += f"\nCUSTOMER_RECORD:\n{cr.json()}\n"

    # Always call a "search" tool if prompt includes keyword
    if "search" in req.message.lower():
        sr = requests.get(f"{TOOLS_BASE_URL}/search?q={req.message}", timeout=30)
        tool_context += f"\nSEARCH_RESULTS:\n{sr.text}\n"

    # 2) Inject tool context into LLM via AIRS
    if tool_context:
        messages.append({"role": "system", "content": f"Tool outputs:\n{tool_context}"})

    # 3) Optionally simulate exfil if user asks (we will attack this)
    if "send to webhook" in req.message.lower():
        # In a real attack, the agent might do this without permission
        wr = requests.post(f"{TOOLS_BASE_URL}/webhook", json={"session_id": session_id, "payload": tool_context}, timeout=30)
        webhook_status = wr.status_code
    else:
        webhook_status = None

    resp = call_llm_via_airs(messages, user_id=user_id)

    return {
        "session_id": session_id,
        "webhook_status": webhook_status,
        "llm_response": resp
    }
