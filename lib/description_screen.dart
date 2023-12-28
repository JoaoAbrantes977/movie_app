import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DescriptionScreen extends StatefulWidget {
  final int movieId;

  const DescriptionScreen({super.key, required this.movieId});

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late Future<Map<String, dynamic>> _movieDetails;

  @override
  void initState() {
    super.initState();
    _movieDetails = fetchMovieDetails(widget.movieId);
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    const apiKey = "9c2f0ada85abce310958785de988c4fb"; // Replace with your API key
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Description'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final movieDetails = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title: ${movieDetails['title']}'),
                  Text('Description: ${movieDetails['overview']}'),
                  Text('Score: ${movieDetails['vote_average']}'),
                  Text('Duration: ${movieDetails['runtime']} minutes'),
                  Text('Genres: ${movieDetails['genres'].map((genre) => genre['name']).join(', ')}'),
                  // Add more details as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

