import 'package:flutter/material.dart';
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
    // Fetch favorite movie ids from your server
    fetchFavoriteMovies();
  }

  Future<void> fetchFavoriteMovies() async {
    final userIdDB = userId; // Replace with your user id
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


  Future<void> fetchTMDBMovieDetails() async {
    const tmdbApiKey = "9c2f0ada85abce310958785de988c4fb"; // Replace with your TMDB API key

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

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w200$posterPath',
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
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

