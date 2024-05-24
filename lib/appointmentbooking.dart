import 'package:flutter/material.dart';
import 'homepage.dart';
import 'speciality.dart';


class Appointment extends StatelessWidget {
  final String Patient_ID;

  const Appointment({Key? key, required this.Patient_ID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          AppointmentBooking(Patient_ID: Patient_ID),
        ]),
      ),
    );
  }
}

class AppointmentBooking extends StatelessWidget {
  final String Patient_ID;

  const AppointmentBooking({Key? key, required this.Patient_ID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 360,
          height: 1319,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
          child: Stack(
            children: [
              buildSpecialityRow(context, 0, 'Primary Care Physician (PCP)', 202),
              buildSpecialityRow(context, 1, 'Cardiologist', 324),
              buildSpecialityRow(context, 2, 'Dermatologist', 463),
              buildSpecialityRow(context, 3, 'ENT Specialist', 601),
              buildSpecialityRow(context, 4, 'Oncologist', 723),
              buildSpecialityRow(context, 5, 'Physical Therapist (PT)', 845),
              buildSpecialityRow(context, 6, 'Speech-Language Pathologist', 984),
              buildSpecialityRow(context, 7, 'Dietitian/Nutritionist', 1122),
              Positioned(
                left: -2,
                top: -56,
                child: Container(
                  width: 364,
                  height: 183,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 2,
                        top: 11,
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
                        left: 0,
                        top: 0,
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
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 42,
                top: 84,
                child: Text(
                  'Appointment Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 86,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => homepage(Patient_ID: Patient_ID)),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 26,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Sort Left.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Positioned buildSpecialityRow(BuildContext context, int index, String Specialization, double topPosition) {
    return Positioned(
      left: 22,
      top: topPosition,
      
      child: GestureDetector(
        
        onTap: () 
        {
          Navigator.push(
            
            context,
            
            MaterialPageRoute(
              builder: (context) => Speciality( Specialization: Specialization, Patient_ID: Patient_ID),
              
            ),
          );
        },
        child: Container(
          width: 311,
          height: 76,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Color(0xFFFDFFFE),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 0.50, color: Color(0xFFDDDEDF)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Specialization,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
