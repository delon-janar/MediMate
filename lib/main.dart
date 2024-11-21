import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/notification_page.dart';

void main() {
  runApp(MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(), // Halaman utama.
        '/notification': (context) =>
            NotificationScreen(), // Halaman notifikasi.
      },
    );
  }
}
