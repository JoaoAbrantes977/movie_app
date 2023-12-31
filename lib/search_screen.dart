import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'description_screen.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({Key? key}) : super(key: key);

  @override
  _SearchMovieState createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  TextEditingController _searchController = TextEditingController();
  List<MovieSuggestion> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Search for a movie",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "ex: The Godfather",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.clear),
                ),
              ),
              onChanged: _getSuggestions,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  MovieSuggestion suggestion = _suggestions[index];

                  return GestureDetector(
                    onTap: () {
                      // Adicione a lógica para lidar com o clique no filme aqui
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DescriptionScreen(movieId: suggestion.id),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${suggestion.posterPath}',
                            width: 40,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rating: ${suggestion.rating}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // obtem a informação dos filmes atraves da API do TMDB
  Future<void> _getSuggestions(String query) async {

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiKey = '9c2f0ada85abce310958785de988c4fb';
    final String baseUrl = 'https://api.themoviedb.org/3/search/movie';

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final Uri uri = Uri.parse('$baseUrl?api_key=$apiKey&query=$query&page=1&include_adult=false');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        final List<MovieSuggestion> suggestions = results.map((result) {
          return MovieSuggestion(
            title: result['title'].toString(),
            posterPath: result['poster_path'] != null
                ? result['poster_path'].toString()
                : '',
            rating: result['vote_average'] != null
                ? result['vote_average'].toDouble()
                : 0.0,
            id: result['id'],
          );
        }).toList();

        setState(() {
          _suggestions = suggestions;
        });
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _suggestions.clear();
    });
  }
}

// classe movie
class MovieSuggestion {
  final String title;
  final String posterPath;
  final double rating;
  final int id;

  MovieSuggestion({
    required this.title,
    required this.posterPath,
    required this.rating,
    required this.id,
  });
}
