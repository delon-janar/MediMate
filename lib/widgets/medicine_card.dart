import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String medicineName;
  final String time;
  final String dosage; 

  const MedicineCard({
    super.key,
    required this.medicineName,
    required this.time,
    required this.dosage, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(
          Icons.medical_services,
          color: Color(0xFF4FC3F7),
        ),
        title: Text(
          medicineName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Waktu minum: $time"),
            Text("Dosis: $dosage"), 
          ],
        ),
      ),
    );
  }
}