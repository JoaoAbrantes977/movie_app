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
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  "Search for a movie",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white54,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "ex: The Godfather",
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.white,
              ),
              onChanged: _getSuggestions,
            ),
            SizedBox(height: 20),
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
                      contentPadding: EdgeInsets.all(8),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${suggestion.posterPath}',
                            width: 40,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rating: ${suggestion.rating}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
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

  Future<void> _getSuggestions(String query) async {
    final String apiKey = '9c2f0ada85abce310958785de988c4fb'; // Substitua pela sua própria chave da API TMDb
    final String baseUrl = 'https://api.themoviedb.org/3/search/movie';

    // Evite chamadas desnecessárias para consultas vazias
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
}

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
