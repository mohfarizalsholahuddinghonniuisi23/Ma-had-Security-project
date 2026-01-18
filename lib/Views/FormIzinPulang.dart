import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:perizinan_santri/models/izin_pulang.dart';
import 'package:perizinan_santri/services/izin_service.dart';

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

  // Service untuk Firestore
  final IzinService _izinService = IzinService();
  
  // State untuk loading
  bool _isLoading = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // Untuk Flutter Web

  // Tanggal pulang
  DateTime? _tanggalPulang;

  // Taggal kembali 
  DateTime? _tanggalKembali;

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _alamatController.dispose();
    _noTelpWaliController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  // Fungsi untuk pilih tanggal
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPulang ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Pulang',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null && picked != _tanggalPulang) {
      setState(() {
        _tanggalPulang = picked;
      });
    }
  }

  // Fungsi untuk pilih tanggal kembali
  Future<void> _pilihTanggalKembali() async {
    // Validasi: tanggal pulang harus dipilih dulu
    if (_tanggalPulang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Pilih tanggal pulang terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKembali ?? _tanggalPulang!.add(const Duration(days: 1)),
      firstDate: _tanggalPulang!, // Minimal setelah tanggal pulang
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Kembali',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null && picked != _tanggalKembali) {
      setState(() {
        _tanggalKembali = picked;
      });
    }
  }

  // Fungsi simpan ke Firestore
  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      // Validasi tanggal
      if (_tanggalPulang == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal pulang'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Set loading
      setState(() {
        _isLoading = true;
      });

      try {
        String? fotoBase64;
        
        // Konversi foto ke base64 jika ada
        if (_selectedImage != null && _selectedImageBytes != null) {
          fotoBase64 = base64Encode(_selectedImageBytes!);
          print('✅ Foto dikonversi ke base64 (${(fotoBase64.length / 1024).toStringAsFixed(1)} KB)');
        }
        
        // Buat object IzinPulang dari form
        final izinBaru = IzinPulang(
          namaSantri: _namaController.text.trim(),
          nis: _nisController.text.trim(),
          alamat: _alamatController.text.trim(),
          noTelpWali: _noTelpWaliController.text.trim(),
          alasan: _alasanController.text.trim(),
          status: 'Disetujui',
          statusSantri: 'Pulang', // Otomatis set status santri = Pulang
          tanggalPulang: _tanggalPulang!,
          tanggalKembali: _tanggalKembali,
          fotoBase64: fotoBase64,
        );

        // Simpan ke Firestore
        await _izinService.tambahIzinPulang(izinBaru);

        // Tampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Data izin pulang berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          _resetForm();
        }
      } catch (e) {
        // Tampilkan pesan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Matikan loading
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
      _tanggalPulang = null;
      _tanggalKembali = null;
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  // Fungsi untuk ambil foto langsung dari kamera
  Future<void> _ambilFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 50,
      );
      
      // const photo = null; // DISABLED FOR DEBUG

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedImage = photo;
          _selectedImageBytes = bytes;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto berhasil dipilih!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk hapus foto
  void _hapusFoto() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto dihapus'),
        duration: Duration(seconds: 2),
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

              // 📅 Date Picker untuk Tanggal Pulang
              InkWell(
                onTap: _pilihTanggal,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pulang',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tanggalPulang != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(_tanggalPulang!)
                            : 'Pilih tanggal pulang',
                        style: TextStyle(
                          color: _tanggalPulang != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 📅 Date Picker untuk Tanggal Kembali
              InkWell(
                onTap: _pilihTanggalKembali,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Kembali (Opsional)',
                    prefixIcon: Icon(Icons.event_available),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tanggalKembali != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(_tanggalKembali!)
                            : 'Pilih tanggal kembali (opsional)',
                        style: TextStyle(
                          color: _tanggalKembali != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          if (_tanggalKembali != null)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _tanggalKembali = null;
                                });
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
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

              // Ambil Foto
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange.shade50,
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null && _selectedImageBytes != null) ...[
                      // Preview foto yang diambil
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _selectedImageBytes!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: _hapusFoto,
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Foto berhasil diambil',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _ambilFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Ulang'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Colors.orange,
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
                        'Ambil foto langsung dari kamera',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _ambilFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan dengan Loading
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpanData,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Data'),
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
