import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

// Acede a classe User
User user = User.userInstance;
String userEmail = user.email;
String userId = user.id;

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

  //movieIdDescription vem da requisição feita na API
  // ENVIA O ID DO USER E O ID DO FILME
  Future<void> favmovie(String movieIdDescription, String idUser) async {
   //print("$movieIdDescription $idUser");
    final responseRegister = await http.post(
      Uri.parse('http://10.0.2.2:3000/insertMovie'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'idUser': idUser,
        'idMovie': movieIdDescription,
      }),
    );

    if (responseRegister.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Succefully added to your Favorites"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (responseRegister.statusCode == 400) {
      // Email already exists, show a SnackBar
      final Map<String, dynamic> errorData = jsonDecode(responseRegister.body);
      final String errorMessage = errorData['error'];
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

  // REQUISIÇÃO À API DO TMDB PARA CARREGAR OS DADOS DE UM FILME POR ID
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
            final movieIdDescription = movieDetails['id'].toString();

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
                  ElevatedButton(
                      onPressed: () => favmovie(movieIdDescription,userId),
                      child: const Text("Add to Favorites"))
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