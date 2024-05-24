import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  final String Patient_ID;

  ChatbotPage({required this.Patient_ID});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _response = 'Please Wait!! Let me think...';
    });

    final url = Uri.parse('http://127.0.0.1:5000/chatbot');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        'Patient_ID': widget.Patient_ID,
      }),
    );

  
    if (response.statusCode == 200) {
      try {
        final decodedResponse = json.decode(response.body);
        

        if (decodedResponse.containsKey('message')) {
          setState(() {
            _response = decodedResponse['message'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _response = 'Message not found in response';
            _isLoading = false;
          });
        }
      } catch (error) {
        print('Error decoding response: $error');
        setState(() {
          _response = 'Error decoding response';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _response = 'Failed to get response from server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your message',
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final message = _controller.text;
                _sendMessage(message);
                _controller.clear();
              },
              child: Text('Send'),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Please Wait!! Let me think...'),
              ),
          ],
        ),
      ),
    );
  }
}
