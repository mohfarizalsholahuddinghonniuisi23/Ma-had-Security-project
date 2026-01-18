import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perizinan_santri/Views/HomeKeamanan.dart';
import 'package:perizinan_santri/Views/login.dart';
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
    // Firebase initialized
  } catch (e) {
    // Silent error or log if critical
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
      // Gunakan AuthWrapper untuk cek status login
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/keamanan': (context) => const HomeKeamanan(),
        '/pengurus': (context) => const HomePengurus(),
      },
    );
  }
}

/// AuthWrapper: Widget yang memutuskan tampilkan Login atau Home
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream dari Firebase Auth yang memantau status login
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1️ Sedang loading (mengecek status)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2️ Cek apakah ada user yang login
        if (snapshot.hasData && snapshot.data != null) {
          // Ada user yang login!
          return const HomeKeamanan();
        } else {
          // Tidak ada user yang login
          return const LoginScreen();
        }
      },
    );
  }
}
