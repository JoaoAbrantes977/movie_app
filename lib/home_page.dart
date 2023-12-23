import 'package:flutter/material.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("A minha app"),
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}
