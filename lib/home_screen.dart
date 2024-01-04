import 'package:flutter/material.dart';
import 'package:movie_app/description_screen.dart';
import 'package:movie_app/favorites_screen.dart';
import 'package:movie_app/login.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/search_screen.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final String apiKey = "9c2f0ada85abce310958785de988c4fb";

  Future<List<Map<String, dynamic>>> fetchMovies(String endpoint) async {

    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$endpoint?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie DB'),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavoriteScreen()),
            );
          }
        },
      ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchMovies('popular'),
          builder: (context, popularMoviesSnapshot) {
            if (popularMoviesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (popularMoviesSnapshot.hasError) {
              return const Center(child: Column(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 50,
                  ),
                  Text("Please check your Internet Connection"),
                ],
              )
              );
            } else {
              final List<Map<String, dynamic>> popularMovies = popularMoviesSnapshot.data!;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchMovies('top_rated'),
                builder: (context, topRatedMoviesSnapshot) {
                  if (topRatedMoviesSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (topRatedMoviesSnapshot.hasError) {
                    return const Center(child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: 50,
                        ),
                        Text("Please check your Internet Connection"),
                      ],
                    )
                    );
                  } else {
                    final List<Map<String, dynamic>> topRatedMovies = topRatedMoviesSnapshot.data!;

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchMovies('upcoming'),
                      builder: (context, upcomingMoviesSnapshot) {
                        if (upcomingMoviesSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (upcomingMoviesSnapshot.hasError) {
                          return const Center(child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 50,
                              ),
                              Text("Please check your Internet Connection"),
                            ],
                          )
                          );
                        } else {
                          final List<Map<String, dynamic>> upcomingMovies = upcomingMoviesSnapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  children: [
                                    const Text("Trending Movies"),
                                    const SizedBox(height: 10,),
                                    CarouselSlider(
                                      items: popularMovies.map((movie) {
                                        return Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                          fit: BoxFit.cover,
                                        );
                                      }).toList(),
                                      options: CarouselOptions(
                                        height: 200.0,
                                        enlargeCenterPage: true,
                                        autoPlay: true,
                                        aspectRatio: 16 / 9,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enableInfiniteScroll: true,
                                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                        viewportFraction: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Vertical ListView for Top Rated Movies
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Top Rated Movies'),
                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: topRatedMovies.length,
                                        itemBuilder: (context, index) {
                                          final movie = topRatedMovies[index];
                                           //print(topRatedMovies[0]);
                                          final movieId = movie['id'];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DescriptionScreen(movieId: movieId),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.network(
                                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Vertical ListView for Upcoming Movies
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Upcoming Movies'),
                                    SizedBox(
                                      height: 149,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: upcomingMovies.length,
                                        itemBuilder: (context, index) {
                                          final movie = upcomingMovies[index];
                                          final movieId = movie['id'];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DescriptionScreen(movieId: movieId),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.network(
                                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                                fit: BoxFit.cover,
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
                          );
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        ),
    );
  }
}