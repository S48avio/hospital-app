from flask import Flask, request, jsonify
from pymongo import MongoClient
from flask_cors import CORS
import hashlib
from bson import ObjectId
import google.generativeai as genai

from datetime import datetime, timedelta
import random
import os
import requests

GOOGLE_API_KEY = 'AIzaSyDLdxqrm1DMDnEdnX9o###e90x2QU'
genai.configure(api_key=GOOGLE_API_KEY)

model = genai.GenerativeModel('gemini-pro')

app = Flask(__name__)
CORS(app)

# MongoDB client setup
client = MongoClient('mongodb+srv://v1l.mongodb.net/')
db = client['test']
users_collection = db['App_users']
prescriptions_collection = db['Prescriptions']
appointments_collection = db['appointments']
bills_collection = db['Bills']
medicines_collection = db['Medicine']
medical_records_collection=db['medical_records']

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

@app.route('/check_appointments', methods=['POST'])
def check_appointments():
    data = request.get_json()
    Patient_ID = data['Patient_ID']

    # Connect to the appointments collection in the Website database
    appointments_collection = db['appointments']

    # Query the appointments collection to find the appointment for the given Patient_ID
    appointment = appointments_collection.find_one({'Patient_ID': Patient_ID})

    if appointment:
        # Retrieve the appointment details
        Name = appointment.get('Name', None)
        Appointment_ID = appointment.get('Appointment_ID', None)
        Patient_ID = appointment.get('Patient_ID', None)
        Token = appointment.get('Token', None)
        print(Name, Appointment_ID, Patient_ID, Token)

        if Name and Appointment_ID and Patient_ID and Token:
            # Get the current smallest token value
            min_token = appointments_collection.find_one(sort=[("Token", 1)])["Token"]

            # Calculate approximate waiting time in minutes
            waiting_time = (Token - min_token) * 10

            return jsonify({
                'status': 'success',
                'message': 'Appointment Found',
                'Name': Name,
                'Appointment_ID': Appointment_ID,
                'Patient_ID': Patient_ID,
                'Token': Token,
                'min_token': min_token,
                'waiting_time': waiting_time
            })
        else:
            # Return an error message if any of the required fields are missing
            return jsonify({'status': 'error', 'message': 'Appointment details incomplete'}), 500
    else:
        # Return an error message if appointment not found
        return jsonify({'status': 'error', 'message': 'Appointment not found for the patient'}), 404

# Register new user
@app.route('/register', methods=['POST'])
def register():
    data = request.json

    # Extract and validate input data
    Name = data.get('Full_name')
    Email = data.get('Email')
    Password = data.get('Password')
    Age = data.get('Age')
    Phone = data.get('Phone')
    Patient_ID = data.get('Patient_ID')

    if not all([Name, Email, Password, Age, Phone, Patient_ID]):
        return jsonify({'message': 'All fields are required'}), 400

    if not validate_email(Email):
        return jsonify({'message': 'Invalid email format'}), 417

    if len(Password) < 5:
        return jsonify({'message': 'Password must be at least 8 characters long'}), 420

    if users_collection.find_one({'Email': Email}):
        return jsonify({'message': 'Email already exists'}), 409

    if users_collection.find_one({'Patient_ID': Patient_ID}):
        return jsonify({'message': 'Patient ID already exists'}), 415

    try:
        Hashed_password = hash_password(Password)
        user_data = {
            'Name': Name,
            'Email': Email,
            'Password': Hashed_password,
            'Age': Age,
            'Phone': Phone,
            'Patient_ID': Patient_ID,
        }
        users_collection.insert_one(user_data)
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        print(f"Error inserting user: {e}")
        return jsonify({'message': 'Internal server error'}), 500

def validate_email(Email):
    import re
    Email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(Email_regex, Email) is not None

@app.route('/get_medical_records', methods=['POST'])
def get_medical_records():
    data = request.json
    Patient_ID = data.get('Patient_ID')

    # Query the medical_records collection to find records for the given Patient_ID
    medical_records = medical_records_collection.find({'Patient_ID': Patient_ID})

    if medical_records:
        # Convert ObjectId to string for JSON serialization
        medical_records_list = [{**record, '_id': str(record['_id'])} for record in medical_records]

        return jsonify({'status': 'success', 'medical_records': medical_records_list}), 200
    else:
        return jsonify({'status': 'error', 'message': 'No medical records found for the patient'}), 404

# Login existing user
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    Patient_ID = data.get('Patient_ID')
    Password = data.get('Password')

    user = users_collection.find_one({'Patient_ID': Patient_ID})

    if user and user['Password'] == hash_password(Password):
        return jsonify({'message': 'Login successful'}), 200
    else:
        return jsonify({'message': 'Invalid Patient_ID or password'}), 401

# Get doctors by specialization
@app.route('/doctors/<Specialization>', methods=['GET'])
def get_doctors_by_Specialization(Specialization):
    print(Specialization)
    doctors_collection = db['doctors']
    doctors = doctors_collection.find({'Specialization': Specialization})
    doctors_list = [{**doctor, '_id': str(doctor['_id'])} for doctor in doctors]
    print(doctors_list)
    return jsonify(doctors_list), 200

# Get minimum token number
@app.route('/min_token', methods=['GET'])
def get_min_token():
    tokens = appointments_collection.distinct('Token')
    min_token = min(set(range(1, max(tokens) + 2)) - set(tokens)) if tokens else 1
    return jsonify({"min_token": min_token})

# Book appointment
@app.route('/appointments', methods=['POST'])
def book_appointment():
    data = request.get_json()

    Name = data.get('Name')
    Age = data.get('Age')
    description = data.get('description')
    startDate = data.get('startDate')
    date = datetime.now().isoformat()
    Appointment_ID = random.randint(1000, 9999)
    Patient_ID = data.get('Patient_ID')
    Doctor_ID = data.get('Doctor_ID')  # Accept Doctor_ID from the request

    # Get the minimum token number
    response = get_min_token()
    Token = response.get_json().get("min_token")

    if not all([Name, Age, description, startDate, Patient_ID, Doctor_ID]):
        return jsonify({"error": "Missing required fields"}), 400

    appointment = {
        "Name": Name,
        "Age": Age,
        "description": description,
        "StartDate": startDate,
        "date": date,
        "Appointment_ID": Appointment_ID,
        "Patient_ID": Patient_ID,
        "Doctor_ID": Doctor_ID,  # Include Doctor_ID in the appointment data
        "Token": Token
    }

    appointments_collection.insert_one(appointment)
    return jsonify({"message": "Appointment booked successfully"}), 200

@app.route('/generate_bill', methods=['POST'])
def generate_bill():
    data = request.json
    Patient_ID = data.get('Patient_ID')
    
    # Find prescription by Patient_ID
    prescription = prescriptions_collection.find_one({'Patient_ID': Patient_ID})
    
    if not prescription:
        return jsonify({'message': 'No prescription found for this Patient_ID'}), 440

    Medicine_name = prescription['Prescription1']['Medicine']
    Quantity = prescription['Prescription1']['Quantity']

    # Find medicine cost by name in the nested structure
    medicine_doc = medicines_collection.find_one({"medicines.medicine": Medicine_name}, {"medicines.$": 1})
    
    if not medicine_doc or 'medicines' not in medicine_doc:
        return jsonify({'message': f'No medicine found with name {Medicine_name}'}), 404

    Cost_per_unit = medicine_doc['medicines'][0]['cost']
    Total_cost = Cost_per_unit * Quantity

    # Get the current date and time
    Current_date = datetime.now().isoformat()

    # Create a new bill record
    bill = {
        'Patient_ID': Patient_ID,
        'Medicine_name': Medicine_name,
        'Quantity': Quantity,
        'Cost_per_unit': Cost_per_unit,
        'Total_cost': Total_cost,
        'date': Current_date
    }
    
    bills_collection.insert_one(bill)

    return jsonify({
        'message': 'Bill generated successfully',
        'Patient_ID': Patient_ID,
        'Medicine_name': Medicine_name,
        'Quantity': Quantity,
        'Cost_per_unit': Cost_per_unit,
        'Total_cost': Total_cost,
        'date': Current_date
    }), 200

# Process the request using Gemini
@app.route('/chatbot', methods=['POST'])
def chatbot():
    # Get JSON data from the request
    data = request.json
    print(data.get("Patient_ID"))

    response = model.generate_content(data.get('message'))

    # Extract relevant information from the response
    message = response.candidates[0].content.parts[0].text
    print(message)

    # Return the response as JSON
    return jsonify({"message": message}), 200

if __name__ == '__main__':
    app.run(debug=True)
