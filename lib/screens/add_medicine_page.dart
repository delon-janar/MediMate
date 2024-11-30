import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  final Function(Map<String, String>) addMedicine;
  final Map<String, String>? initialData;
  final Function(Map<String, String>)? onSave;

  const FormScreen({
    super.key,
    required this.addMedicine,
    this.initialData,
    this.onSave,
  });

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _medicineName;
  late String _dosage;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _medicineName = widget.initialData!['name']!;
      _dosage = widget.initialData!['dosage'] ?? '';
      _time = TimeOfDay(
        hour: int.parse(widget.initialData!['time']!.split(":")[0]),
        minute:
            int.parse(widget.initialData!['time']!.split(":")[1].split(" ")[0]),
      );
    } else {
      _medicineName = '';
      _dosage = '';
      _time = TimeOfDay.now();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final medicineData = {
        'name': _medicineName,
        'dosage': _dosage,
        'time': _time.format(context),
      };
      if (widget.onSave != null) {
        widget.onSave!(medicineData);
      } else {
        widget.addMedicine(medicineData);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData != null ? "Edit Obat" : "Tambah Obat"),
        backgroundColor:
            const Color.fromARGB(255, 143, 175, 255), // Biru lembut
        elevation: 6.0,
        shadowColor: const Color.fromARGB(255, 199, 182, 255), // Bayangan ungu
      ),
      backgroundColor:
          const Color.fromARGB(255, 240, 245, 255), // Latar belakang biru pucat
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _medicineName,
                decoration: InputDecoration(
                  labelText: 'Nama Obat',
                  filled: true,
                  fillColor: const Color.fromARGB(
                      255, 248, 248, 255), // Latar belakang TextField
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama obat tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _medicineName = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _dosage,
                decoration: InputDecoration(
                  labelText: 'Dosis',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 248, 248, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dosis tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dosage = value!;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    "Waktu Minum: ${_time.format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (picked != null) {
                        setState(() {
                          _time = picked;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 175, 255),
                    ),
                    child: const Text("Pilih Waktu"),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey, // Tombol Batal tetap abu-abu
                    ),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 175, 255),
                    ),
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
