import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:perizinan_santri/Views/FormIzinPulang.dart';
import 'package:perizinan_santri/services/auth_service.dart';
import 'package:perizinan_santri/services/izin_service.dart';
import 'package:perizinan_santri/models/izin_pulang.dart';
// import 'package:perizinan_santri/Views/login.dart'; // Removed to prevent circular dependency

class HomeKeamanan extends StatefulWidget {
  const HomeKeamanan({super.key});

  @override
  State<HomeKeamanan> createState() => _HomeKeamananState();
}

class _HomeKeamananState extends State<HomeKeamanan> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final IzinService _izinService = IzinService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  // Fungsi verifikasi kembali
  Future<void> _verifikasiKembali(IzinPulang izin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Kembali'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfirmasi bahwa santri berikut telah kembali:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${izin.namaSantri}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('NIS: ${izin.nis}'),
                  if (izin.isTerlambat())
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('TERLAMBAT', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _izinService.verifikasiKembali(izin.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${izin.namaSantri} telah diverifikasi kembali'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal verifikasi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Fungsi lihat foto detail
  void _showFotoDetail(String nama, String base64Foto) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Foto: $nama'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: Image.memory(
                  base64Decode(base64Foto),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Gagal memuat foto'),
                    )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget card untuk izin aktif
  Widget _buildIzinAktifCard(IzinPulang izin) {
    final isTerlambat = izin.isTerlambat();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTerlambat 
            ? const BorderSide(color: Colors.red, width: 2) 
            : (izin.status == 'Belum Disetujui' ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan badge terlambat
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: izin.fotoBase64 != null 
                      ? MemoryImage(base64Decode(izin.fotoBase64!)) 
                      : null,
                  backgroundColor: isTerlambat ? Colors.red.shade100 : Colors.teal.shade100,
                  child: izin.fotoBase64 == null 
                      ? Text(
                          izin.namaSantri[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isTerlambat ? Colors.red : Colors.teal,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        izin.namaSantri,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('NIS: ${izin.nis}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (isTerlambat)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('TERLAMBAT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else if (izin.status == 'Belum Disetujui')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('MENUNGGU', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            // Info tanggal
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Pulang: ${DateFormat('dd MMM yyyy').format(izin.tanggalPulang)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                if (izin.tanggalKembali != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.event_available, size: 16, color: isTerlambat ? Colors.red : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Kembali: ${DateFormat('dd MMM yyyy').format(izin.tanggalKembali!)}',
                    style: TextStyle(fontSize: 13, color: isTerlambat ? Colors.red : Colors.grey[700]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    izin.alamat,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Tombol lihat foto jika ada
            if (izin.fotoBase64 != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showFotoDetail(izin.namaSantri, izin.fotoBase64!),
                child: Row(
                  children: [
                    const Icon(Icons.image, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Foto Bukti',
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Tombol verifikasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _verifikasiKembali(izin),
                icon: const Icon(Icons.check_circle),
                label: const Text('Verifikasi Kembali'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTerlambat ? Colors.orange : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget card untuk riwayat
  Widget _buildRiwayatCard(IzinPulang izin) {
    final isTerlambat = izin.isTerlambat();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: izin.fotoBase64 != null 
                      ? MemoryImage(base64Decode(izin.fotoBase64!)) 
                      : null,
                  child: izin.fotoBase64 == null 
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(izin.namaSantri, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('NIS: ${izin.nis}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (isTerlambat)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Terlambat', style: TextStyle(color: Colors.orange[800], fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Pulang: ${DateFormat('dd/MM/yy').format(izin.tanggalPulang)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Text(' → ', style: TextStyle(color: Colors.grey)),
                Text(
                  'Kembali: ${izin.tanggalVerifikasiKembali != null ? DateFormat('dd/MM/yy').format(izin.tanggalVerifikasiKembali!) : '-'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            // Tombol lihat foto jika ada
            if (izin.fotoBase64 != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showFotoDetail(izin.namaSantri, izin.fotoBase64!),
                child: Row(
                  children: [
                    const Icon(Icons.image, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Foto Bukti',
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keamanan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Izin Aktif'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.security, size: 35, color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'Petugas Keamanan',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ma\'had Security',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.orange),
              title: const Text('Buat Izin Pulang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FormIzinPulang()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Izin Aktif
          StreamBuilder<List<IzinPulang>>(
            stream: _izinService.getIzinAktif(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Tidak ada santri yang sedang izin', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                );
              }
              
              final izinList = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: izinList.length,
                itemBuilder: (context, index) => _buildIzinAktifCard(izinList[index]),
              );
            },
          ),
          // Tab Riwayat
          StreamBuilder<List<IzinPulang>>(
            stream: _izinService.getRiwayatIzin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Belum ada riwayat izin', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                );
              }
              
              final izinList = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: izinList.length,
                itemBuilder: (context, index) => _buildRiwayatCard(izinList[index]),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FormIzinPulang())),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Buat Izin Pulang',
      ),
    );
  }
}
