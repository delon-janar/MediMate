import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String medicineName;
  final String time;

  const MedicineCard({
    Key? key,
    required this.medicineName,
    required this.time,
  }) : super(key: key);

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
        subtitle: Text("Waktu minum: $time"),
      ),
    );
  }
}