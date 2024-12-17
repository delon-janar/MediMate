import 'package:flutter/material.dart';
import 'package:ngobatyuk/main.dart'; // Pastikan ini sesuai dengan lokasi file main.dart
import '../widgets/medicine_card.dart';
import 'package:provider/provider.dart';
import 'add_medicine_page.dart';
import 'detail_medicine_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _medicineList = [];
  List<Map<String, String>> _filteredMedicineList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> _loadMedicines() async {
    try {
      final filePath = await _getFilePath('medicines.txt');
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonMedicines = jsonDecode(contents);
        setState(() {
          _medicineList = jsonMedicines
              .map((item) => Map<String, String>.from(item))
              .toList();
          _filteredMedicineList = _medicineList;
        });
      }
    } catch (e) {
      print('Error loading medicines: $e');
    }
  }

  Future<void> _saveMedicines() async {
    try {
      final filePath = await _getFilePath('medicines.txt');
      final file = File(filePath);
      await file.writeAsString(jsonEncode(_medicineList));
    } catch (e) {
      print('Error saving medicines: $e');
    }
  }

  Future<void> _addReminder(Map<String, dynamic> reminder) async {
    try {
      final filePath = await _getFilePath('reminders.txt');
      final file = File(filePath);

      List<Map<String, dynamic>> reminders = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonReminders = jsonDecode(contents);
        reminders = jsonReminders
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      // Add the new reminder
      reminders.add({
        "time": reminder["time"] ?? "Unknown Time",
        "active": reminder["active"] ?? true, // Ensure active is a bool
      });

      // Save the updated reminders list
      await file.writeAsString(jsonEncode(reminders));
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  Future<void> _loadReminders() async {
    try {
      final filePath = await _getFilePath('reminders.txt');
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonReminders = jsonDecode(contents);
        setState(() {
          // Just print or use the reminders list for now
          print("Loaded reminders: $jsonReminders");
        });
      }
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  void _addMedicine(Map<String, String> medicine) {
    setState(() {
      _medicineList.add(medicine);
      _filterMedicines();
      _saveMedicines();

      _addReminder({
        "time": medicine["time"] ?? "Unknown Time",
        "active": true, 
      }).then((_) {
        _loadReminders(); 
      });
    });
  }
  
  void _deleteMedicine(String name) {
    setState(() {
      _medicineList.removeWhere((medicine) => medicine['name'] == name);
      _filterMedicines();
      _saveMedicines();
    });
  }

  void _editMedicine(Map<String, String> updatedMedicine) {
    setState(() {
      final index = _medicineList.indexWhere((medicine) =>
          medicine['name'] == updatedMedicine['name']);
      if (index != -1) {
        _medicineList[index] = updatedMedicine;
        _filterMedicines();
        _saveMedicines();
      }
    });
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicineList = _medicineList.where((medicine) {
        final medicineName = medicine['name']!.toLowerCase();
        return medicineName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MediMate',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pengingat minum obatmu!',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.grey[850]
            : const Color.fromARGB(255, 143, 175, 255),
        elevation: 6.0,
        shadowColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.black45
            : const Color.fromARGB(255, 199, 182, 255),
        actions: [
          Row(
            children: [
              const Text(
                "Dark Mode",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notification').then((_) {
                // When returning to NotificationPage, ensure it reloads the reminders
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.themeMode == ThemeMode.dark
              ? const LinearGradient(
                  colors: [Color(0xFF212121), Color(0xFF37474F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari Obat',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                itemCount: _filteredMedicineList.length,
                itemBuilder: (context, index) {
                  final medicine = _filteredMedicineList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMedicinePage(
                            medicineName: medicine['name']!,
                            time: medicine['time']!,
                            dosage: medicine['dosage']!,
                            onDelete: _deleteMedicine,
                            onEdit: _editMedicine,
                            addMedicine: _addMedicine,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.grey[800]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: MedicineCard(
                          medicineName: medicine['name']!,
                          time: medicine['time']!,
                          dosage: medicine['dosage']!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 143, 175, 255),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormScreen(addMedicine: _addMedicine),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}