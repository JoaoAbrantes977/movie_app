import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DescriptionScreen extends StatefulWidget {
  final int movieId;

  const DescriptionScreen({Key? key, required this.movieId}) : super(key: key);

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
    const apiKey = "9c2f0ada85abce310958785de988c4fb"; // Substitua pela sua própria chave da API
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&append_to_response=credits'),
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
        title: Text('Movie Details'),
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
            final List<dynamic> cast = movieDetails['credits']['cast'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movieDetails['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Body Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          movieDetails['overview'] ?? 'No description available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Score: ${movieDetails['vote_average']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Duration: ${movieDetails['runtime']} minutes',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Genres: ${movieDetails['genres'].map((genre) => genre['name']).join(', ')}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cast:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Lista de Atores
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cast.length,
                            itemBuilder: (context, index) {
                              final actor = cast[index];
                              return Container(
                                width: 80, // Ajuste a largura conforme necessário
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: actor['profile_path'] != null
                                            ? NetworkImage('https://image.tmdb.org/t/p/w200${actor['profile_path']}')
                                            : AssetImage('assets/placeholder.jpg') as ImageProvider,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      actor['name'],
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
