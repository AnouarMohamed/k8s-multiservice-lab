import os
import redis
from flask import Flask, jsonify

app = Flask(__name__)

r = redis.Redis(
    host=os.environ.get('REDIS_HOST', 'stg-redis-svc'),
    port=int(os.environ.get('REDIS_PORT', 6379)),
    decode_responses=True,
    socket_connect_timeout=3
)

@app.route('/')
def index():
    try:
        count = r.incr('hits')
        env = os.environ.get('APP_ENV', 'unknown')
        return jsonify({'hits': count, 'env': env, 'status': 'ok'})
    except Exception as e:
        return jsonify({'status': 'error', 'detail': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
