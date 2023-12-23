import 'package:flutter/material.dart';
import 'package:movie_app/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class LoginForm extends StatelessWidget {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Logica do login
                String email = emailController.text;
                String password = passController.text;
                verifyUser(email, password, context);
                print('Login Button Pressed\nEmail: $email\nPassword: $password');
                print("Registado com sucesso");
              },
              child: const Text('Login'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implement register logic here
                String email = emailController.text;
                String password = passController.text;
                createUser(email, password, context);
                print('Register Button Pressed\nEmail: $email\nPassword: $password');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


// CREATE USER
Future<void> createUser(String email, String password, context) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': email,
      'pass': password,
    }),
  );

  if (response.statusCode == 200) {
    // User created successfully, navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );

  } else if (response.statusCode == 400) {
    // Email already exists, show a SnackBar
    final Map<String, dynamic> errorData = jsonDecode(response.body);
    final String errorMessage = errorData['error'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    // Unexpected error, show a generic SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// VERIFY USER

Future<void> verifyUser(String email, String password, context) async{

  // esta vai ser um get
}