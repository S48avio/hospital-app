# Hospital Appointment Management App

## Overview
This app is designed to streamline the hospital appointment process, enhance patient experience, and provide additional functionalities for a seamless healthcare journey. 

## Features
1. **Symptom-Based Appointment Booking**:
    - Patients can book appointments by describing their symptoms.
    - Uses a Random Forest classifier to predict consultation times based on symptoms.

2. **Dynamic Waiting Time Updates**:
    - Real-time updates on waiting times.
    - Recalculates and adjusts waiting times dynamically as each consultation progresses.
    - Notifies patients about expected consultation times and any changes due to the actual consultation durations.

3. **Bill Payments During Consultation**:
    - Patients can make bill payments using Google Pay during their consultation.

4. **Viewing Reports and Prescriptions**:
    - Patients can access and view medical reports and prescriptions made by their doctors.

5. **Gemini Chatbot for Query Answering**:
    - A chatbot powered by Gemini AI answers patient queries.

6. **Automatic Medication Reminders**:
    - Automatically sends notifications to patients for taking their prescribed medications using Firebase Cloud Messaging (FCM).

## Technology Stack

- **Frontend**: Flutter
- **Backend**: Flask (Python)
- **Database**: MongoDB
- **Machine Learning**: Random Forest classifier
- **Payments**: Google Pay integration
- **Notifications**: Firebase Cloud Messaging (FCM)
- **AI Chatbot**: Gemini AI

## Installation

### Prerequisites

- Flutter SDK
- Python 3.x
- MongoDB
- Google Pay API credentials
- Firebase project setup

### Backend Setup

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/hospital-appointment-app.git
    cd hospital-appointment-app/backend
    ```

2. **Create a virtual environment**:
    ```bash
    python3 -m venv env
    source env/bin/activate
    ```

3. **Install the dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4. **Run the Flask app**:
    ```bash
    flask run
    ```

### Frontend Setup

1. **Navigate to the frontend directory**:
    ```bash
    cd ../frontend
    ```

2. **Install Flutter dependencies**:
    ```bash
    flutter pub get
    ```

3. **Run the Flutter app**:
    ```bash
    flutter run
    ```

## Usage

1. **Book an Appointment**:
    - Describe your symptoms to book an appointment.
    - The app will predict your consultation time and schedule the appointment.

2. **Real-Time Updates**:
    - Receive real-time updates on waiting times.
    - Notifications will be sent about expected consultation times and any changes.

3. **During Consultation**:
    - Make bill payments using Google Pay.
    - The doctor will update your reports and prescriptions in the app.

4. **Access Reports and Prescriptions**:
    - View your medical reports and prescriptions anytime through the app.

5. **Chatbot Interaction**:
    - Use the Gemini chatbot for any queries related to your health or the app's features.

6. **Medication Reminders**:
    - Receive automatic notifications for taking your prescribed medications.

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.



## Contact

For any questions or issues, please open an issue in the repository or contact [saviosunny48@gmail.com].
