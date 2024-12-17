import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();

    // Initialize notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');
      },
    );

    createNotificationChannel();
    requestNotificationPermission();
    _loadReminders(); // Load reminders from file
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'MedimateID', // ID
      'MediMate', // Name
      description: 'This channel is used for Medimate.', // Description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted.');
    } else {
      print('Notification permission denied.');
    }
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/reminders.txt';
  }

  Future<void> _loadReminders() async {
  try {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonReminders = jsonDecode(contents);
      setState(() {
        reminders = jsonReminders.map((item) {
          // Ensure 'active' is always a bool
          return {
            "time": item["time"] ?? "Unknown Time",
            "active": item["active"] ?? true, // Default 'active' to true
          };
        }).toList();
      });
    }
  } catch (e) {
    print('Error loading reminders: $e');
  }
}

  Future<void> _saveReminders() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final jsonReminders = jsonEncode(reminders);
      await file.writeAsString(jsonReminders);
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  void _toggleNotification(int index) {
    setState(() {
      reminders[index]['active'] = !reminders[index]['active'];
      if (reminders[index]['active']) {
        _scheduleNotification(index);
      } else {
        _cancelNotification(index);
      }
      _saveReminders();
    });
  }

  void _addReminder() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          reminders.add({
            'time': pickedTime.format(context),
            'active': true,
          });
          _scheduleNotification(reminders.length - 1);
          _saveReminders();
        });
      }
    });
  }

  void _editReminder(int index) {
    final currentTime = reminders[index]['time'];
    final timeParts = currentTime.split(' ');
    final hourMinute = timeParts[0].split(':');
    final hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';

    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: isPM ? (hour % 12 + 12) : hour,
        minute: minute,
      ),
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          final timeFormat = pickedTime.format(context);
          reminders[index]['time'] = timeFormat;

          if (reminders[index]['active']) {
            // Reschedule notification with updated time
            _scheduleNotification(index);
          }
          _saveReminders(); // Save updated reminders
        });
      }
    });
  }

  void _deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reminders.removeAt(index);
              });
              Navigator.pop(context);
              _cancelNotification(index);
              _saveReminders();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _scheduleNotification(int index) {
    final timeString = reminders[index]['time'];
    final timeParts = timeString.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final isPM = timeParts[1] == 'PM';

    final now = DateTime.now();
    final hour24 = hour % 12 + (isPM ? 12 : 0);

    // Ensure the time is for the next occurrence if it is already past
    DateTime notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour24,
      minute,
    );
    if (notificationTime.isBefore(now)) {
      notificationTime = notificationTime.add(const Duration(days: 1));
    }

    final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'MedimateID',
        'MediMate',
        channelDescription: 'This channel is used for Medimate.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
      index, // Unique ID for notification
      'Time To Take Your Meds', // Notification title
      'Hey! do not forget to take your medicine, it is time for your daily intake', // Notification body
      tzDateTime, // Scheduled time
      notificationDetails, // Notification details
      androidAllowWhileIdle: true, // Allow notification while idle
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat at the same time
    ).then((_) {
      print('Notification scheduled for: $tzDateTime');
    }).catchError((error) {
      print('Failed to schedule notification: $error');
    });
  }

  void _cancelNotification(int index) {
    flutterLocalNotificationsPlugin.cancel(index).then((_) {
      print('Notification cancelled for ID: $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _loadReminders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Page'),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.grey[850]
            : const Color.fromARGB(255, 143, 175, 255),
      ),
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF1F1F1),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Card(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[800]
                : Colors.white,
            child: ListTile(
              title: Text(
                'Reminder at ${reminder['time']}',
                style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit, 
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.grey[800]),
                    onPressed: () => _editReminder(index),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete, 
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.red[300]
                            : Colors.red),
                    onPressed: () => _deleteReminder(index),
                  ),
                  // Toggle switch
                  Switch(
                    value: reminder['active'],
                    onChanged: (value) {
                      _toggleNotification(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.blueGrey
            : const Color.fromARGB(255, 143, 175, 255),
        child: const Icon(Icons.add),
      ),
    );
  }


}
