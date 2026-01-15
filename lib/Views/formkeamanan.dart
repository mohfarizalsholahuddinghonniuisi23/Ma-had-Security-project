import 'package:flutter/material.dart';

class formkeamanan extends StatefulWidget {
  const formkeamanan({super.key});

  @override
  State<formkeamanan> createState() => _formkeamananState();
}

class _formkeamananState extends State<formkeamanan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _alasanController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _formKey.currentState?.reset();
      _namaController.clear();
      _nisController.clear();
      _alasanController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Izin Santri'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input NIS
              TextFormField(
                controller: _nisController,
                decoration: const InputDecoration(
                  labelText: 'NIS (Nomor Induk Santri)',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIS tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Alasan
              TextFormField(
                controller: _alasanController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Izin',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _simpanData,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}