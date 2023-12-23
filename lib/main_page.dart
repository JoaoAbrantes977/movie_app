import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/widget_tree.dart';

class Main_Page extends StatelessWidget {
  const Main_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Movie App"),
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}

// basicamente vou ter de criar um Navigator da home_page.dart para a main_page.dart
// tenho de mover o botão signout para o sidebar