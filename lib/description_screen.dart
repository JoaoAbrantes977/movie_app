import 'package:flutter/material.dart';
import 'package:movie_app/home_screen.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Movie Description",
      home: HomeScreen(),
    );
  }
}
