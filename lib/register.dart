import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class Register extends StatelessWidget {
  final TextEditingController FullNameController = TextEditingController();
  final TextEditingController PatientIdController = TextEditingController();
  final TextEditingController AgeController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PhoneController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final TextEditingController ConfirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF18C4D4), Color(0xFF0072CE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField("Full Name", Icons.person, FullNameController),
              SizedBox(height: 10),
              _buildTextField("Patient ID", Icons.confirmation_num,
                  PatientIdController),
              SizedBox(height: 10),
              _buildTextField("Age", Icons.calendar_today, AgeController),
              SizedBox(height: 10),
              _buildTextField("Email", Icons.email, EmailController),
              SizedBox(height: 10),
              _buildTextField("Phone", Icons.phone, PhoneController),
              SizedBox(height: 10),
              _buildTextField(
                  "Password", Icons.lock, PasswordController, true),
              SizedBox(height: 10),
              _buildTextField("Confirm Password", Icons.lock_outline,
                  ConfirmPasswordController, true),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => register(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Color(0xFF18C4D4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, IconData icon,
      TextEditingController controller, [bool isObscureText = false]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    String FullName = FullNameController.text;
    String Patient_ID = PatientIdController.text;
    String Age = AgeController.text;
    String Email = EmailController.text;
    String Phone = PhoneController.text;
    String Password = PasswordController.text;
    String ConfirmPassword = ConfirmPasswordController.text;

    if (Password != ConfirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (Password.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 5 characters long')),
      );
      return;
    }

    // Optional: Add more input validation for other fields

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'Full_name': FullName,
          'Patient_ID': Patient_ID,
          'Age': Age,
          'Email': Email,
          'Phone': Phone,
          'Password': Password,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      } else if (response.statusCode == 415) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email format')),
        );
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User with this email already exists')),
        );
      } else if (response.statusCode == 415) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User with this patient ID already exists')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register')),
        );
      }
    } catch (e) {
      print('Error registering user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register. Please try again later')),
      );
    }
  }
}
