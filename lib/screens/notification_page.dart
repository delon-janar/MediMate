import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
          reminders = jsonReminders
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
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
      'Hey! Do not forget to take your medicine, it is time for your daily intake', // Notification body
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
    // Get current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: isDarkMode ? Colors.grey[850] : const Color.fromARGB(255, 143, 175, 255),
        elevation: 6.0,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.7) : const Color.fromARGB(255, 199, 182, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black87, Colors.grey[900]!]
                : [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              child: ListTile(
                title: Text('Time: ${reminders[index]['time']}',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editReminder(index);
                      },
                    ),
                    Switch(
                      value: reminders[index]['active'],
                      onChanged: (value) {
                        _toggleNotification(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteReminder(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add),
        backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
      ),
    );
  }
}
