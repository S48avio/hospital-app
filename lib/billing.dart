import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

class Billing extends StatefulWidget {
  final String Patient_ID; // Accept patient_ID as a required parameter

  Billing({required this.Patient_ID, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BillingPage();
}

class _BillingPage extends State<Billing> {
  List<Map<String, dynamic>> bills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/generate_bill'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'Patient_ID': widget.Patient_ID,
        }),
      );
      print('Response status code: ${response.statusCode}'); 
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          final billData = json.decode(response.body);
          bills = [
            {
              'Medicine_name': billData['medicine_name'],
              'Quantity': billData['Quantity'],
              'Total_cost': billData['Total_cost'],
            }
          ];
          isLoading = false;
        });
      } else {
        // Handle errors
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch bills')),
        );
      }
    } catch (e) {
      // Handle network errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch bills. Please try again later')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => homepage(Patient_ID: widget.Patient_ID)),
            );
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text('My Bills'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xffd9d9d9),
                    boxShadow: const [
                      BoxShadow(
                        color: const Color(0x3f000000),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine: ${bill['medicine_name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xff000000),
                          fontFamily: 'RobotoRoman-Regular',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quantity: ${bill['quantity']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xff000000),
                          fontFamily: 'RobotoRoman-Regular',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Cost: ${bill['total_cost']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xff000000),
                          fontFamily: 'RobotoRoman-Regular',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Add payment logic here
                          print('Payment button pressed');
                        },
                        child: Text('Pay Now'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
