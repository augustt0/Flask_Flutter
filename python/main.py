# Flask files
# pip install Flask
import flask
from flask import request, jsonify
from flask import json

# Tinydb
# pip install tinydb
from tinydb import TinyDB, Query

# Extras
import os

app = flask(__name__)


# Get the current working directory
cwd = os.getcwd()

# Initialize database
db = TinyDB('{0}/db.json'.format(cwd))

table = db.table(f'users')

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

# Function to generate error messages / responses
def gen_error(message):
    response = jsonify({
        'status': 'ERROR',
        'message': message
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

# SAVE USER DATA
def saveUserData(username,name,lastname,email,phone):
    # Does the user exists?
    user = Query()
    reply = table.search(user.username == username)
    if len(reply) > 0:
        # It exists
        gen_error('User already exists.')
    else:
        # It's new
        table.insert({'username': username,'name': name, 'lastname': lastname, 'email': email, 'phone': phone})

# UPLOAD USER DATA
@app.route('/api/v1/uploads/users', methods=['POST'])
def uploadUserData():
    if request.method == 'POST':
        username=request.json['username']
        name=request.json['name']
        lastname=request.json['lastname']
        email=request.json['email']
        phone=request.json['phone']
        
        # Verify all data fields
        if name == None or lastname == None or phone == None or email == None:
            return gen_error('There are missing data fields.')
        else:
            # Data verified, we save in tinydb
            saveUserData(username,name,lastname,email,phone)
            response = jsonify({
                    'status': 'SUCCESS',
                    'message': 'Successfully received data'
                })
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response
    else:
        return gen_error('Wrong method.')

# SHOW USER DATA
def getUserData(username):
    # Does the user exists?
    user = Query()
    reply = table.search(user.username == username)
    if len(reply) > 0:
        # It exists
        gen_error('User already exists.')
        return [reply[0]['username'],reply[0]['name'],reply[0]['lastname'],reply[0]['email'],reply[0]['phone']],
    else:
        gen_error('User does not exist.')

# RETRIEVE USER DATA
@app.route('/api/v1/uploads/users/<username>', methods=['GET'])
def retrieveUserData(username):
    if request.method == 'GET':
        # Verify all data fields
        if username == None:
            return gen_error('There are missing data fields.')
        else:
            # Data verified, we save in tinydb
            username,name,lastname,email,phone = getUserData(username)
            response = jsonify({
                    'status': 'SUCCESS',
                    'message': 'Successfully received data',
                    'data': {
                        'username': username,
                        'name': name,
                        'lastname': lastname,
                        'email': email,
                        'phone': phone
                    }
                })
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response
    else:
        return gen_error('Wrong method.')