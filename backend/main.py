from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
load_dotenv()

from routers import ai, checklists

app = FastAPI(title="SuaraWarga AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai.router, prefix="/api")
app.include_router(checklists.router, prefix="/api/checklists")

@app.get("/")
def read_root():
    return {"status": "Backend is running!"}
