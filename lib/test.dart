import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homepage.dart'; // Import your homepage file

class Schedule extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String patient_ID; // Change patient_ID to non-nullable String

  Schedule({required this.doctor, required this.patient_ID}); // Update patient_ID to non-nullable

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final _formKey = GlobalKey<FormState>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> startDateOptions = [
    '1 Day',
    '2 Days',
    '3 Days',
    'A Week Ago',
    'Two Weeks Ago',
    'One Month Before'
  ];

  String? selectedStartDate;
  String? name;
  int? age;
  String? description;

  @override
  void initState() {
    super.initState();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Doctor: ${widget.doctor['name']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Speciality: ${widget.doctor['Speciality']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Rating: ${widget.doctor['Rating']?.toString() ?? 'No rating'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                onChanged: (value) {
                  age = int.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Patient ID'),
                initialValue: widget.patient_ID,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Patient ID';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Start Date'),
                value: selectedStartDate,
                onChanged: (newValue) {
                  setState(() {
                    selectedStartDate = newValue;
                  });
                },
                items: startDateOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _bookAppointment();
                  }
                },
                child: Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    final random = Random();
    final appointmentID = random.nextInt(9000) + 1000; // Random 4-digit number
    final currentDate = DateTime.now().toIso8601String();

    // Fetching the minimum token from the backend
    final tokenResponse = await http.get(Uri.parse('http://127.0.0.1:5000/min_token'));
    int token = json.decode(tokenResponse.body)['min_token'];

    final appointmentData = {
      'name': name,
      'age': age,
      'description': description,
      'startDate': selectedStartDate,
      'date': currentDate,
      'appointment_ID': appointmentID,
      'patient_ID': widget.patient_ID,
      'token': token,
    };

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(appointmentData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully')),
      );

      // Send local push notification
      await _showNotification();

      // Navigate to the homepage with patient_ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homepage(patient_ID: widget.patient_ID)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment')),
      );
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel_id', // Channel ID
      'CareWise:Personalized Hospital App', // Channel Name
      // Channel Description
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Appointment Booked', // Notification Title
      'Your appointment has been booked successfully.', // Notification Body
      platformChannelSpecifics,
    );
  }
}
