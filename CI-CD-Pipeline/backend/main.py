# Test CI/CD Pipeline
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.testclient import TestClient
from main import app


app = FastAPI()
client = TestClient(app)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!", "status": "running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}# pipeline trigger

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
