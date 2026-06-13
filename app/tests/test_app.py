import app as service


class FakeRedis:
    def __init__(self):
        self.values = {"hits": "0"}

    def incr(self, key):
        value = int(self.values.get(key, "0")) + 1
        self.values[key] = str(value)
        return value

    def get(self, key):
        return self.values.get(key)

    def ping(self):
        return True


def test_index_increments_hits(monkeypatch):
    monkeypatch.setattr(service, "r", FakeRedis())
    service.app.config.update(TESTING=True)

    response = service.app.test_client().get("/")

    assert response.status_code == 200
    assert response.get_json()["hits"] == 1
    assert response.get_json()["status"] == "ok"


def test_healthz_does_not_require_redis(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    service.app.config.update(TESTING=True)

    response = service.app.test_client().get("/healthz")

    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"
    assert response.get_json()["env"] == "test"


def test_readyz_checks_redis(monkeypatch):
    monkeypatch.setattr(service, "r", FakeRedis())
    service.app.config.update(TESTING=True)

    response = service.app.test_client().get("/readyz")

    assert response.status_code == 200
    assert response.get_json()["redis"] == "ok"
