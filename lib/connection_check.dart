import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
  );
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
