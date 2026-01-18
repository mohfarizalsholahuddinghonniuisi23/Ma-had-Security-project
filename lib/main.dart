import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perizinan_santri/Views/HomeKeamanan.dart';
import 'package:perizinan_santri/Views/login.dart';
import 'package:perizinan_santri/Views/test_firestore.dart';
import 'package:perizinan_santri/Views/HomePengurus.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perizinan Santri',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Gunakan StreamBuilder untuk cek status login
       home: const HomePengurus(),
      
    );
  }
}

/// AuthWrapper: Widget yang memutuskan tampilkan Login atau Home
/// Seperti satpam di pintu yang cek: "Sudah punya kartu akses belum?"
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream dari Firebase Auth yang memantau status login
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('');
        print('═══════════════════════════════════════════════════════════');
        print('🔍 AUTH WRAPPER: Mengecek status login...');
        print('═══════════════════════════════════════════════════════════');

        // 1️⃣ Sedang loading (mengecek status)
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Status: Sedang mengecek...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2️⃣ Cek apakah ada user yang login
        if (snapshot.hasData && snapshot.data != null) {
          // Ada user yang login!
          print('✅ Status: USER SUDAH LOGIN');
          print('👤 Email: ${snapshot.data!.email}');
          print('🆔 UID: ${snapshot.data!.uid}');
          print('➡️ Menampilkan: HomeKeamanan');
          print('═══════════════════════════════════════════════════════════');
          return const HomeKeamanan();
        } else {
          // Tidak ada user yang login
          print('❌ Status: BELUM LOGIN');
          print('➡️ Menampilkan: LoginScreen');
          print('═══════════════════════════════════════════════════════════');
          return const LoginScreen();
        }
      },
    );
  }
}
