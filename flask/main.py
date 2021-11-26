import redis
from flask import Flask,jsonify
app = Flask(__name__)
redis = redis.Redis(host='redis', port=6379, db=0)
@app.route('/')
def holla():
     redis.incr('visitor')
     visitor_num = redis.get('visitor').decode("utf-8")
     return "Holla!  we have hit %s times" % (visitor_num)
@app.route('/health')
def health():
    return jsonify({"status": "UP"}), 200
