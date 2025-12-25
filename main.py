import os
from fastapi import FastAPI
from pydantic import BaseModel


app = FastAPI(
    title="BadMerging API",
    description="Lightweight API wrapper so the Docker image can boot reliably.",
    version="0.1.0",
)


class EchoRequest(BaseModel):
    message: str


@app.get("/")
def root():
    return {"message": "BadMerging API is up"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/config")
def config():
    return {
        "VLLM_BASE_URL": os.getenv("VLLM_BASE_URL"),
        "LLM_MODEL": os.getenv("LLM_MODEL"),
        "DB_URL": os.getenv("DB_URL"),
        "ENABLE_SHELL_EXEC": os.getenv("ENABLE_SHELL_EXEC", "false"),
    }


@app.post("/echo")
def echo(body: EchoRequest):
    return {"echo": body.message}
