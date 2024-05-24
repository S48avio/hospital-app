import 'package:flutter/material.dart';
import 'login.dart'; // Import the Login screen
import 'register.dart'; // Import the Register screen


void main() {
  runApp(const Carewise());
}

class Carewise extends StatelessWidget {
  const Carewise({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          children: [
            Welcome(),
          ],
        ),
      ),
    );
  }
}

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 360,
          height: 800,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFF10394B)),
          child: Stack(
            children: [
              Positioned(
                left: -83,
                top: 0,
                child: Container(
                  width: 516,
                  height: 847,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image 1.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 650,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text('LOGIN'),
                ),
              ),
              Positioned(
                left: 198,
                top: 650,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text('REGISTER'),
                ),
              ),
              Positioned(
                left: 52,
                top: 312,
                child: Container(
                  width: 258,
                  height: 225,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.fill,
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
}
