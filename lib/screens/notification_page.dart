// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> reminders = [
    {'time': '08:00 AM', 'active': true},
    {'time': '12:00 PM', 'active': false},
  ];

  void _toggleNotification(int index) {
    setState(() {
      reminders[index]['active'] = !reminders[index]['active'];
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
        });
      }
    });
  }

  void _deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus Notifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reminders.removeAt(index);
              });
              Navigator.pop(context);
              
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: const Color.fromARGB(255, 143, 175, 255), 
        elevation: 6.0, 
        shadowColor: const Color.fromARGB(255, 199, 182, 255),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Waktu: ${reminders[index]['time']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
      ),
    );
  }
}
