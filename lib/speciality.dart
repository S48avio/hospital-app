import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'schedule.dart'; // Import the Schedule page

class Speciality extends StatefulWidget {
  final String Specialization;
  final String Patient_ID;

  Speciality({required this.Specialization, required this.Patient_ID});

  @override
  _SpecialityState createState() => _SpecialityState();
}

class _SpecialityState extends State<Speciality> {
  List<dynamic> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/doctors/${widget.Specialization}'));
      if (response.statusCode == 200) {
        setState(() {
          doctors = json.decode(response.body);
          print(doctors);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch doctors');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Specialization),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? Center(child: Text('No doctors found for ${widget.Specialization}'))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    return buildDoctorCard(doctors[index]);
                  },
                ),
    );
  }

  Widget buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/Menu.png'),  // replace with the doctor's image if available
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['Name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xff107031),
                    fontFamily: 'LeagueSpartan-Medium',
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  'Speciality: ${doctor['Specialization'] ?? 'Specialization'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xff000000),
                    fontFamily: 'LeagueSpartan-Light',
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  'Rating: ${doctor['Rating']?.toString() ?? 'No rating'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xff000000),
                    fontFamily: 'LeagueSpartan-Light',
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Schedule(
                    doctor: doctor,
                    Patient_ID: widget.Patient_ID, // Pass patient_ID to Schedule page
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff107031),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/Sort Left.png', width: 17, height: 17),
                SizedBox(width: 5),
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'LeagueSpartan-Regular',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
