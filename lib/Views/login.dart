import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../Views/HomeKeamanan.dart';
import '../Views/HomePengurus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ═══════════════════════════════════════════════════════════
  // 📦 VARIABEL-VARIABEL YANG DIBUTUHKAN
  // ═══════════════════════════════════════════════════════════

  // Form key untuk validasi
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil nilai dari TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Service untuk login
  final AuthService _authService = AuthService();

  // State untuk UI
  bool _isLoading = false; // Apakah sedang proses login?
  bool _obscurePassword = true; // Apakah password disembunyikan?
  String? _errorMessage; // Pesan error jika ada

  // ═══════════════════════════════════════════════════════════
  // 🗑️ DISPOSE: Bersihkan memory saat widget dihapus
  // ═══════════════════════════════════════════════════════════
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 FUNGSI LOGIN
  // ═══════════════════════════════════════════════════════════
  Future<void> _login() async {
    // 1️⃣ Validasi form dulu
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika form tidak valid
    }

    // 2️⃣ Set loading = true (tampilkan loading)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 3️⃣ Panggil AuthService untuk login
      final credential = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 4️⃣ Ambil role user dari Firestore
      String? role;
      final userEmail = credential.user?.email ?? '';
      
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user?.uid)
            .get();
        
        if (snapshot.exists && snapshot.data()?['role'] != null) {
          role = snapshot.data()?['role'] as String?;
          print('✅ Role dari Firestore: $role');
        } else {
          // Role tidak ada di Firestore, tentukan dari email
          print('ℹ️ Role tidak ditemukan di Firestore, mendeteksi dari email...');
          
          if (userEmail.contains('keamanan')) {
            role = 'keamanan';
          } else if (userEmail.contains('pengurus')) {
            role = 'pengurus';
          }
          
          // Simpan role ke Firestore untuk login berikutnya
          if (role != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(credential.user?.uid)
                .set({
              'email': userEmail,
              'name': role == 'keamanan' ? 'Admin Keamanan' : 'Admin Pengurus',
              'role': role,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            print('✅ Role "$role" disimpan ke Firestore');
          }
        }
      } catch (e) {
        print('⚠️ Error fetching role: $e');
        // Fallback: tentukan dari email
        if (userEmail.contains('keamanan')) {
          role = 'keamanan';
        } else if (userEmail.contains('pengurus')) {
          role = 'pengurus';
        }
      }

      // 5️⃣ Arahkan ke dashboard sesuai role
      if (mounted) {
        if (role == 'keamanan') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeKeamanan()),
          );
        } else if (role == 'pengurus') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePengurus()),
          );
        } else {
          // Jika role tidak dikenali, tampilkan error
          setState(() {
            _errorMessage = 'Role user tidak dikenali. Gunakan email dengan kata "keamanan" atau "pengurus".';
          });
        }
      }
    } catch (e) {
      // 6️⃣ Jika gagal, tampilkan error
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      // 7️⃣ Matikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🎨 BUILD UI
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ══════════════════════════════════════════
                  // 🔒 ICON & JUDUL
                  // ══════════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Ma\'had Security',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Sistem Keamanan Ma\'had',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ══════════════════════════════════════════
                  // 📋 CARD FORM LOGIN
                  // ══════════════════════════════════════════
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ══════════════════════════════════
                          // 📧 INPUT EMAIL
                          // ══════════════════════════════════
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              // Cek format email sederhana
                              if (!value.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ══════════════════════════════════
                          // 🔑 INPUT PASSWORD
                          // ══════════════════════════════════
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // Tombol untuk show/hide password
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // ══════════════════════════════════
                          // ❌ PESAN ERROR (jika ada)
                          // ══════════════════════════════════
                          if (_errorMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ══════════════════════════════════
                          // 🔘 TOMBOL LOGIN
                          // ══════════════════════════════════
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ══════════════════════════════════════════
                  // ℹ️ INFO BANTUAN
                  // ══════════════════════════════════════════
                  const Text(
                    'Hubungi admin jika lupa password',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
