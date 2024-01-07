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

  const DescriptionScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late Future<Map<String, dynamic>> _movieDetails;
  late String movieIdDescription;

  @override
  void initState() {
    super.initState();
    _movieDetails = fetchMovieDetails(widget.movieId);
  }

  // Adiciona o filme favorito ao utilizador na base de dados
  Future<void> favmovie(String movieIdDescription, String idUser) async {
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
          content: Text("Successfully added to your Favorites"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (responseRegister.statusCode == 400) {
      // Email already exists
      final Map<String, dynamic> errorData = jsonDecode(responseRegister.body);
      final String errorMessage = errorData['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Unexpected error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Vai buscar os detalhes do filme à API  do TMDB
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    const apiKey = "9c2f0ada85abce310958785de988c4fb";
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
        title: const Text('Movie Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _movieDetails.then((movieDetails) {
                movieIdDescription = movieDetails['id'].toString();
                favmovie(movieIdDescription, userId);
              });
            },
          ),
        ],
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
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}',
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movieDetails['title'],
                          style: const TextStyle(
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
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          movieDetails['overview'] ?? 'No description available',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Score: ${movieDetails['vote_average']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Duration: ${movieDetails['runtime']} minutes',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Genres: ${movieDetails['genres'].map((genre) => genre['name']).join(', ')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cast:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cast.length,
                            itemBuilder: (context, index) {
                              final actor = cast[index];
                              return Flexible(
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundImage: actor['profile_path'] != null
                                              ? NetworkImage('https://image.tmdb.org/t/p/w200${actor['profile_path']}')
                                              : const AssetImage('assets/placeholder.jpg') as ImageProvider,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        actor['name'],
                                        style: const TextStyle(fontSize: 11),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
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
