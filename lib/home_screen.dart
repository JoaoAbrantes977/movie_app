import 'package:flutter/material.dart';
import 'package:movie_app/description_screen.dart';
import 'package:movie_app/login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              subtitle: Text("1.0.0"),
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
          if(index == 0){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DescriptionScreen()),
            );
          } else if (index == 1){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DescriptionScreen()),
            );
          }
          else{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DescriptionScreen()),
            );

          }
        },
      ),
    );
  }
}
