import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:provider/provider.dart';
import 'screens/notification_page.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MedicineReminderApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MedicineReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Medicine Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // Untuk light mode
        scaffoldBackgroundColor: Colors.white, // Warna background untuk light mode
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue, // Warna tombol plus di light mode
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // Untuk dark mode
        scaffoldBackgroundColor: Colors.black, // Warna background untuk dark mode
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850], // Warna appBar untuk dark mode
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey, // Warna tombol plus di dark mode
        ),
      ),
      themeMode: themeProvider.themeMode, // Gunakan themeMode dari ThemeProvider
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(), // Halaman utama.
        '/notification': (context) =>
            NotificationScreen(), // Halaman notifikasi.
      },
    );
  }
}
