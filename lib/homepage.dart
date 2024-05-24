

//homepage.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appointmentbooking.dart';
import 'billing.dart';
import 'chatbot.dart';
import 'reports.dart';

class homepage extends StatefulWidget {
  final String Patient_ID;

  const homepage({Key? key, required this.Patient_ID}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<homepage> {
  bool hasAppointment = false;
  String Name = "";
  int Appointment_ID = 0;
  String Patient_ID = "";
  int Token = 0;
  int minToken = 0;
  int waitingTime = 0; // Variable for waiting time

  @override
  void initState() {
    super.initState();
    _checkAppointments(widget.Patient_ID);
  }

  Future<void> _checkAppointments(String Patient_ID) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/check_appointments'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Patient_ID': Patient_ID,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final appointmentsFound = jsonData['status'] == 'success';
      print(appointmentsFound);
      print(jsonData);
      if (appointmentsFound) {
        setState(() {
          hasAppointment = true;
          Name = jsonData['Name'];
          Appointment_ID = jsonData['Appointment_ID'];
          Patient_ID = jsonData['Patient_ID'];
          Token = jsonData['Token'];
          minToken = jsonData['min_token'];
          waitingTime = jsonData['waitingTime']; // Calculate waiting time
        });
      } else {
        setState(() {
          hasAppointment = false;
        });
      }
    } else {
      setState(() {
        hasAppointment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Container(
                  width: 362,
                  height: hasAppointment ? 1306 : 1140, // Adjust height based on whether appointment exists
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                  child: Stack(
                    children: [
                      _buildHeader(),
                      if (hasAppointment) _buildAppointmentDetails(),
                      _buildFeatureBox(
                        context,
                        "Appointment Booking",
                        "assets/Event Accepted.png",
                        hasAppointment ? 470 : 196,
                        Appointment(Patient_ID: widget.Patient_ID),
                      ),
                      _buildFeatureBox(
                        context,
                        "Billing",
                        "assets/Bill.png",
                        hasAppointment ? 698 : 464,
                        Billing(Patient_ID: widget.Patient_ID),
                      ),
                      _buildFeatureBox(
                        context,
                        "ChatBot",
                        "assets/Chatbot.png",
                        hasAppointment ? 924 : 690,
                        ChatbotPage(Patient_ID: widget.Patient_ID),
                      ),
                      _buildFeatureBox(
                        context,
                        "Reports",
                        "assets/Report Card.png",
                        hasAppointment ? 1150 : 916,
                        Report(Patient_ID: widget.Patient_ID),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: -6,
          child: Container(
            width: 360,
            height: 172,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Intersect.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Positioned(
          left: -2,
          top: -17,
          child: Container(
            width: 364,
            height: 183,
            decoration: ShapeDecoration(
              color: Color(0xBA062C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Positioned(
          left: 48,
          top: 111,
          child: Text(
            'CAREWISE HOSPITAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w100,
              height: 0,
            ),
          ),
        ),
        Positioned(
          left: 13,
          top: -2,
          child: Container(
            width: 35,
            height: 68,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Menu.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails() {
    return Positioned(
      left: 30,
      top: 150,
      child: Container(
        width: 299,
        height: 200,
        decoration: BoxDecoration(
          color: Color(0xFF19698D),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Name: $Name',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Appointment ID: $Appointment_ID',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Patient ID: $Patient_ID',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'My Token: $Token',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Current Token: $minToken',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Waiting Time: $waitingTime minutes', // Display the waiting time
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBox(BuildContext context, String title, String asset, double top, Widget page) {
    return Positioned(
      left: 30,
      top: top,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          width: 299,
          height: 141,
          decoration: BoxDecoration(
            color: Color(0xFF19698D),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 129,
                top: 50,
                child: Container(
                  width: 41,
                  height: 59,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(asset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 58,
                top: 100,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
