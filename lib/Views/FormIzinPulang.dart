import 'package:flutter/material.dart';

class FormIzinPulang extends StatefulWidget {
  const FormIzinPulang({super.key});

  @override
  State<FormIzinPulang> createState() => _FormIzinPulangState();
}

class _FormIzinPulangState extends State<FormIzinPulang> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelpWaliController = TextEditingController();
  final _alasanController = TextEditingController();
  
  String? _selectedStatus;
  final List<String> _statusOptions = ['Belum Disetujui', 'Disetujui'];

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _alamatController.dispose();
    _noTelpWaliController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStatus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih status izin'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data izin pulang berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      _resetForm();
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nisController.clear();
    _alamatController.clear();
    _noTelpWaliController.clear();
    _alasanController.clear();
    setState(() {
      _selectedStatus = null;
    });
  }

  void _uploadFoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Fitur upload foto akan segera hadir!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Izin Pulang'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Isi formulir dengan lengkap dan benar',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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

              // Input Alamat
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input No Telp Wali
              TextFormField(
                controller: _noTelpWaliController,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon Wali',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 081234567890',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'No. telepon wali tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'No. telepon minimal 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Izin',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Silakan pilih status izin';
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
                  hintText: 'Jelaskan alasan izin pulang secara detail',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Alasan minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Upload Foto (Coming Soon)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.photo_camera,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bukti Foto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _uploadFoto,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Foto'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _simpanData,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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