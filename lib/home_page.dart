import 'package:flutter/material.dart';
import 'package:movie_app/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("A minha app"),
          backgroundColor: Colors.amber,
        ),
        body: Center(
          child: SizedBox(
            child: ElevatedButton(
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginForm()),
                );
              }, child: const Text("Voltar"),
            ),
          ),
        ),
      ),
    );
  }
}
