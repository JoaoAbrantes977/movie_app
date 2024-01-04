import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/login.dart';

void main() {
  runApp(const MyApp());
}
  /*
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basica_Channel',
            channelName: "Basic Notifications",
            channelDescription: "Notification channel for basic tests")
      ],
    debug: true,
  );
  */
/*
void requestNotificationPermission() async {
  await AwesomeNotifications().requestPermissionToSendNotifications();
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {

  }

}

void scheduleNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'basic_channel',
      title: 'Scheduled Notification',
      body: 'This notification was scheduled at a specific time.',
    ),
    schedule: NotificationCalendar(
      second: DateTime.now().second + 10, // Schedule the notification 10 seconds from now
    ),
  );
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   LoginForm(),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
