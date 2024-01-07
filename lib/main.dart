import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/home_screen.dart';
import 'package:movie_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: snapshot.data == true ? const HomeScreen() : LoginForm(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  // Verifica se a variavél isLogged esta true or false
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool('isLogged') ?? false;
    return isLogged;
  }

}
// muda a variavel para false ou true
void setLoginStatus(BuildContext context, bool isLogged) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLogged', isLogged);
  print("esta true");
}
