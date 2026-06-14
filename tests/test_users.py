import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.user import User

client = TestClient(app)

def test_create_user():
    response = client.post("/users/", json={"name": "Chandan", "email": "chandan@example.com"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Chandan"
    assert data["email"] == "chandan@example.com"
    assert "id" in data

def test_read_users():
    client.post("/users/", json={"name": "Reader", "email": "reader@example.com"})

    response = client.get("/users/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert any(u["email"] == "reader@example.com" for u in users)

def test_update_user():
    response = client.post("/users/", json={"name": "Test", "email": "test@example.com"})
    user_id = response.json()["id"]

    response = client.put(f"/users/{user_id}", json={"name": "Updated", "email": "updated@example.com"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated"
    assert data["email"] == "updated@example.com"

def test_delete_user():
    response = client.post("/users/", json={"name": "DeleteMe", "email": "deleteme@example.com"})
    user_id = response.json()["id"]

    response = client.delete(f"/users/{user_id}")
    assert response.status_code == 200

    response = client.get(f"/users/{user_id}")
    assert response.status_code == 404

@pytest.fixture(autouse=True)
def cleanup():
    yield
    db = SessionLocal()
    db.query(User).delete()
    db.commit()
    db.close()
