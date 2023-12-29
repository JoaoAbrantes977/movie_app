import 'package:flutter/material.dart';
import 'package:movie_app/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Class User criada para guardar o email e o id do utilizador que faz login

class User {
  late String _id;
  late String _email;

  User(this._email, this._id);

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  static User? _userInstance;

  static User get userInstance {
    _userInstance ??= User("default_email", "default_id");
    return _userInstance!;
  }

  static void setUserInstance(User user) {
    _userInstance = user;
  }
}


class LoginForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Logica do login
                String email = emailController.text;
                String password = passController.text;
                verifyUser(email, password, context);
                print(
                    'Login Button Pressed\nEmail: $email\nPassword: $password');
                print("Login efetuado com sucesso");
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // register logic
                String email = emailController.text;
                String password = passController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  createUser(email, password, context);
                  print(
                      'Login Button Pressed\nEmail: $email\nPassword: $password');
                  print("Registo efetuado com sucesso");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User and Password cannot be empty"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

// CREATE USER //
Future<void> createUser(String email, String password, context) async {
  final responseRegister = await http.post(
    Uri.parse('http://10.0.2.2:3000/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': email,
      'pass': password,
    }),
  );

  if (responseRegister.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User Signed In Succefully"),
        backgroundColor: Colors.green,
      ),
    );
    // User created successfully, navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  } else if (responseRegister.statusCode == 400) {
    // Email already exists, show a SnackBar
    final Map<String, dynamic> errorData = jsonDecode(responseRegister.body);
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
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// VERIFY USER //
Future<void> verifyUser(String email, String password, context) async {
  final responseLogin = await http.post(
    Uri.parse('http://10.0.2.2:3000/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': email,
      'pass': password,
    }),
  );

  if (responseLogin.statusCode == 200) {

    // User logged in successfully, extract user ID from the response
    final Map<String, dynamic> responseData = jsonDecode(responseLogin.body);
    Map<String, dynamic> userId = responseData['user'];
    final String userIdDB = userId['id'].toString();

    print(userIdDB  + " do login.dart");
    User.setUserInstance(User(email, userIdDB));


    //print("$userId");
    // User logged in successfully, navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  const HomeScreen()),
    );
  } else if (responseLogin.statusCode == 400) {
    // Email or password are not correct
    final Map<String, dynamic> errorData = jsonDecode(responseLogin.body);
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
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
