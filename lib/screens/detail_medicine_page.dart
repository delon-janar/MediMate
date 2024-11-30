import 'package:flutter/material.dart';
import 'add_medicine_page.dart';

class DetailMedicinePage extends StatelessWidget {
  final String medicineName;
  final String time;
  final String dosage; // Tambahkan ini
  final Function(String) onDelete;
  final Function(Map<String, String>) onEdit;
  final Function(Map<String, String>) addMedicine;

  const DetailMedicinePage({super.key, 
    required this.medicineName,
    required this.time,
    required this.dosage, // Tambahkan ini
    required this.onDelete,
    required this.onEdit,
    required this.addMedicine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Obat'),
        backgroundColor: const Color.fromARGB(255, 143, 175, 255),
        elevation: 4,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Obat:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    medicineName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Waktu Minum:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dosis:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    dosage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(
                          addMedicine: addMedicine,
                          initialData: {'name': medicineName, 'time': time, 'dosage': dosage},
                          onSave: (updatedMedicine) {
                            onEdit(updatedMedicine);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 143, 175, 255),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 199, 82, 82),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Obat'),
        content: const Text('Apakah Anda yakin ingin menghapus obat ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete(medicineName);
               Navigator.of(ctx).pop(); // Tutup dialog
            Navigator.of(context).pop(); // Kembali ke HomePage
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935), // Red
          ),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  }
}