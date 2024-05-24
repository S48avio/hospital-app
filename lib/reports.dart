import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the homepage screen
import 'package:http/http.dart' as http;

class Report extends StatefulWidget {
  final String Patient_ID; // Accept patient_ID as a required parameter

  Report({required this.Patient_ID, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CodiaPageState();
}

class _CodiaPageState extends State<Report> {
  Future<void> sendPatientIDToBackend() async {
    final url = 'http://127.0.0.1:5000/get_medical_records'; // Endpoint to fetch medical records

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'Patient_ID': widget.Patient_ID},
      );

      if (response.statusCode == 200) {
        // Parse and display the medical records
        // For now, let's just print the response body
        print(response.body);
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        width: 360,
        height: 800,
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 87,
              child: Text(
                'My Reports',
                textAlign: TextAlign.left,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 30,
                  color: const Color(0xff000000),
                  fontFamily: 'RobotoRoman-SemiBold',
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 12,
              top: 29,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => homepage(Patient_ID: widget.Patient_ID)),
                  ).then((_) {
                    // After navigating back from homepage, send the Patient_ID to the backend
                    sendPatientIDToBackend();
                  });
                },
                child: Image.asset('assets/Left black.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
