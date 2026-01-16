import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perizinan_santri/Views/FormIzinPulang.dart';
import 'package:perizinan_santri/services/auth_service.dart';
import 'package:perizinan_santri/screens/login_screen.dart';

class HomeKeamanan extends StatefulWidget {
  const HomeKeamanan({super.key});

  @override
  State<HomeKeamanan> createState() => _HomeKeamananState();
}

class _HomeKeamananState extends State<HomeKeamanan> {
  // Service untuk logout
  final AuthService _authService = AuthService();

  // Fungsi untuk handle menu sidebar
  void _handleMenuSelection(String menu) {
    Navigator.pop(context); // Tutup drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menu $menu dipilih')),
    );
  }
  // Fungsi untuk logout
  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi
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
      
      // Navigate ke halaman login dan hapus semua route sebelumnya
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false, // Hapus semua route sebelumnya
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Ambil info user yang sedang login
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Keamanan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      // Sidebar Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Drawer dengan info user
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.security,
                      size: 35,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'Petugas Keamanan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ma\'had Security',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            //Menu izin pulang
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Izin Pulang'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormIzinPulang(),
                  ),
                );
              },
            ),
            // Menu Izin Kembali
            ListTile(
              leading: const Icon(Icons.login, color: Colors.teal),
              title: const Text('Izin Kembali'),
              onTap: () => _handleMenuSelection('Izin Kembali'),
            ),

            const Divider(),

            // Menu Logout
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer dulu
                _logout();
              },
            ),
          ],
        ),
      ),

      // Body Content
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sistem Keamanan Ma\'had',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
