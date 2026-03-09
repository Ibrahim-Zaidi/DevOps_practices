from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_generate_qr():
    url = "http://example.com"
    response = client.post("/generate-qr/", params={"url": url})

    assert response.status_code == 200
    assert "qr_code_url" in response.json()

def test_generate_qr_invalid_url():
    url = "invalid-url"
    response = client.post("/generate-qr/", params={"url": url})

    assert response.status_code == 400  # FastAPI validation error