import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/description_screen.dart';
import 'package:movie_app/search_screen.dart';
import 'home_screen.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Acede a classe User
User user = User.userInstance;
String userEmail = user.email;
String userId = user.id;


class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<int> favoriteMovieIds = []; // List to store movie ids from your server
  List<Map<String, dynamic>> moviesData = []; // List to store TMDB movie details

  @override
  void initState() {
    super.initState();
    // Fetch favorite movie ids from the server
    fetchFavoriteMovies();
  }

  // VAI BUSCAR CADA ID DOS FILMES ASSOCIADOS AO ID DE UMA CONTA DE UTILIZADOR
  Future<void> fetchFavoriteMovies() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userIdDB = userId; // id do utilizador
    final url = "http://10.0.2.2:3000/getFavMovies/$userIdDB";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<int> movieIds = responseData.map<int>((item) => item['id_Movie']).toList();
        setState(() {
          favoriteMovieIds = movieIds;
        });
        // Fetch TMDB movie details for each id
        fetchTMDBMovieDetails();
      } else {
        // Handle error
        print("Error fetching favorite movies: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network or server error
      print("Error fetching favorite movies: $e");
    }
  }

// VAI BUSCAR OS DETALHES DO FILME CONFORME O ID DO FILME
  Future<void> fetchTMDBMovieDetails() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    const tmdbApiKey = "9c2f0ada85abce310958785de988c4fb";

    for (final movieId in favoriteMovieIds) {
      final tmdbUrl = "https://api.themoviedb.org/3/movie/$movieId";
      const apiKeyParam = "api_key=$tmdbApiKey";

      try {
        final response = await http.get(Uri.parse("$tmdbUrl?$apiKeyParam"));
        if (response.statusCode == 200) {
          final Map<String, dynamic> movieData = json.decode(response.body);
          setState(() {
            moviesData.add(movieData);
          });
        } else {
          // Handle error
          print("Error fetching TMDB movie details: ${response.statusCode}");
        }
      } catch (e) {
        // Handle network or server error
        print("Error fetching TMDB movie details: $e");
      }
    }
  }

// DELETES THE SELECTED MOVIE BY THE USER
  Future<void> deleteFavoriteMovie(String idMovie) async {
    // userId -> id do utilizador
    // idMovie -> id do filme

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
    }

    final url = Uri.parse('http://10.0.2.2:3000/deleteFavMovies/$userId');

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idMovie": idMovie}),
      );

      if (response.statusCode == 200) {
        print("Successfully removed favorite movie.");

      } else {
        print("Failed to delete favorite movie. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorite Movies"),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile_pic.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              onTap: () {
                // Handle dark mode option
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle settings option
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Version'),
              subtitle: const Text("1.0.0"),
              onTap: () {
                // Handle app version option
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginForm()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: moviesData.length,
        itemBuilder: (BuildContext context, int index) {
          final movie = moviesData[index];
          final String posterPath = movie['poster_path'];
          final String title = movie['title'];
          final idMovie = movie['id'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap:(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescriptionScreen(movieId: idMovie),
                      ),
                    );
                  } ,
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w200$posterPath',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        enableFeedback: true,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remover"),
                                content: const Text("Deseja remover este filme dos favoritos"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // remove o dialog
                                    },
                                    child: const Text('Não'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteFavoriteMovie(idMovie);
                                      Navigator.of(context).pop();
                                      setState(() {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const FavoriteScreen())
                                        );
                                      });
                                    },
                                    child: const Text('Sim'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchMovie()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Already on the Favorites screen
          }
        },
      ),
    );
  }
}

