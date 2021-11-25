import redis
from flask import Flask
app = Flask(__name__)
redis = redis.Redis(host='redis', port=6379, db=0)
@app.route('/')
def hello_world():
     return 'This is a Python Flask Application with redis and accessed through Nginx'
@app.route('/visitor')
def visitor():
     redis.incr('visitor')
     visitor_num = redis.get('visitor').decode("utf-8")
     return "Holla!  we have hit %s times" % (visitor_num)
