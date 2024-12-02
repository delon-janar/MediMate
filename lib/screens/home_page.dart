import 'package:flutter/material.dart';
import '../widgets/medicine_card.dart';
import 'add_medicine_page.dart';
import 'detail_medicine_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _medicineList = [
    {"name": "Paracetamol", "time": "08:00 AM", "dosage": "500mg"},
    {"name": "Vitamin C", "time": "12:00 PM", "dosage": "1000mg"},
  ];

  List<Map<String, String>> _filteredMedicineList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMedicineList = _medicineList;
    _searchController.addListener(_filterMedicines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _addMedicine(Map<String, String> medicine) {
    setState(() {
      _medicineList.add(medicine);
      _filterMedicines();
    });
  }

  void _deleteMedicine(String name) {
    setState(() {
      _medicineList.removeWhere((medicine) => medicine['name'] == name);
      _filterMedicines();
    });
  }

  void _editMedicine(Map<String, String> updatedMedicine) {
    setState(() {
      final index = _medicineList.indexWhere((medicine) => medicine['name'] == updatedMedicine['name']);
      if (index != -1) {
        _medicineList[index] = updatedMedicine;
        _filterMedicines();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color.fromARGB(255, 143, 175, 255),
        elevation: 6.0,
        shadowColor: const Color.fromARGB(255, 199, 182, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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