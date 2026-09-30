import pytest

from app import create_app


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "test-version")

    app = create_app()
    app.config["TESTING"] = True

    with app.test_client() as test_client:
        yield test_client


def test_health(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_version(client):
    response = client.get("/version")

    assert response.status_code == 200
    assert response.get_json() == {
        "service": "developer-service",
        "version": "test-version",
    }


def test_work(client):
    response = client.get("/work")

    assert response.status_code == 200
    assert response.get_json() == {
        "operation": "sum",
        "numbers": [10, 20, 30],
        "result": 60,
    }