import 'package:flutter/material.dart';

class HomeKeamanan extends StatefulWidget {
  const HomeKeamanan({super.key});

  @override
  State<HomeKeamanan> createState() => _HomeKeamananState();
}

class _HomeKeamananState extends State<HomeKeamanan> {
  int _selectedIndex = 0;

  // Fungsi untuk handle menu sidebar
  void _handleMenuSelection(String menu) {
    Navigator.pop(context); // Tutup drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menu $menu dipilih')),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Keamanan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // Sidebar Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Drawer
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
                  const Text(
                    'Sistem Keamanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
              onTap: () => _handleMenuSelection('Izin Pulang'),
            ),
            // Menu Izin Kembali
            ListTile(
              leading: const Icon(Icons.login, color: Colors.teal),
              title: const Text('Izin Kembali'),
              onTap: () => _handleMenuSelection('Izin Kembali'),
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
