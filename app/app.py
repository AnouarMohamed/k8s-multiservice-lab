import os

import redis
from flask import Flask, jsonify

app = Flask(__name__)

r = redis.Redis(
    host=os.environ.get("REDIS_HOST", "redis-svc"),
    port=int(os.environ.get("REDIS_PORT", 6379)),
    decode_responses=True,
    socket_connect_timeout=3,
    socket_timeout=3,
)


def app_metadata():
    return {
        "service": os.environ.get("SERVICE_NAME", "flask-api"),
        "env": os.environ.get("APP_ENV", "unknown"),
        "version": os.environ.get("APP_VERSION", "dev"),
    }


@app.route("/")
def index():
    try:
        count = r.incr("hits")
        return jsonify({**app_metadata(), "hits": count, "status": "ok"})
    except redis.RedisError as exc:
        return jsonify({**app_metadata(), "status": "error", "detail": str(exc)}), 500


@app.route("/healthz")
def healthz():
    return jsonify({**app_metadata(), "status": "healthy"})


@app.route("/readyz")
def readyz():
    try:
        r.ping()
        return jsonify({**app_metadata(), "status": "ready", "redis": "ok"})
    except redis.RedisError as exc:
        return jsonify({**app_metadata(), "status": "not-ready", "detail": str(exc)}), 503


@app.route("/metrics")
def metrics():
    hits = r.get("hits") or "0"
    body = "\n".join(
        [
            "# HELP flask_api_hits_total Total API requests handled by the app.",
            "# TYPE flask_api_hits_total counter",
            f"flask_api_hits_total {hits}",
            "",
        ]
    )
    return app.response_class(body, mimetype="text/plain")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
