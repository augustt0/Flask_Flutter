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

app = flask.Flask(__name__)


# Get the current working directory
cwd = os.getcwd()

# Initialize database at the current working directory
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

# GET USER DATA
@app.route('/api/v1/uploads/users', methods=['POST'])
def uploadUserData():
    if request.method == 'POST':
        username=request.form['username']
        name=request.form['name']
        lastname=request.form['lastname']
        email=request.form['email']
        phone=request.form['phone']
        
        # Verify all data fields
        if username == None or name == None or lastname == None or phone == None or email == None:
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
def showUserData(username):
    # Does the user exists?
    user = Query()
    reply = table.search(user.username == username)
    if len(reply) > 0:
        # It exists
        return reply[0]['username'],reply[0]['name'],reply[0]['lastname'],reply[0]['email'],reply[0]['phone'],
    else:
        gen_error('User does not exist.')

# RETRIEVE USER DATA
@app.route('/api/v1/retrieve/user/<username>')
def retrieveUserData(username):
    # Verify all data fields
    if username == None:
        return gen_error('There are missing data fields.')
    else:
        # Data verified, we save in tinydb
        if showUserData(username) != None:
            username,name,lastname,email,phone = showUserData(username)
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
            return gen_error('No user found.')