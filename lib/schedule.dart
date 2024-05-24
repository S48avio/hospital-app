import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homepage.dart';

class Schedule extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String Patient_ID;

  Schedule({required this.doctor, required this.Patient_ID});

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
  String? Name;
  int? Age;
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
                'Doctor: ${widget.doctor['Name']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Doctor ID: ${widget.doctor['Doctor_ID']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Specialization: ${widget.doctor['Specialization']}',
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
                  Name = value;
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
                  Age = int.tryParse(value);
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
                initialValue: widget.Patient_ID,
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
    final Appointment_ID = random.nextInt(9000) + 1000; // Random 4-digit number
    final currentDate = DateTime.now().toIso8601String();

    final tokenResponse = await http.get(Uri.parse('http://127.0.0.1:5000/min_token'));
    int Token = json.decode(tokenResponse.body)['min_token'];

    final appointmentData = {
      'Name': Name,
      'Age': Age,
      'description': description,
      'startDate': selectedStartDate,
      'date': currentDate,
      'Appointment_ID': Appointment_ID,
      'Patient_ID': widget.Patient_ID,
      'Doctor_ID': widget.doctor['Doctor_ID'],  // Add Doctor_ID here
      'Token': Token,
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

      // Send web browser notification
      _sendWebBrowserNotification();

      // Navigate to the homepage with patient_ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homepage(Patient_ID: widget.Patient_ID)),
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
      'appointment_channel_id',
      'CareWise: Personalized Hospital App',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('iphone_sound.mp3'), // Add sound here
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Appointment Booked',
      'Your appointment has been booked successfully.',
      platformChannelSpecifics,
    );
  }

  void _sendWebBrowserNotification() {
    final notificationTitle = 'Appointment Booked';
    final notificationBody = 'Your appointment has been booked successfully.';

    if (html.Notification.supported) {
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(notificationTitle, body: notificationBody);
        }
      });
    } else {
      print('Web browser notifications not supported');
    }
  }
}
