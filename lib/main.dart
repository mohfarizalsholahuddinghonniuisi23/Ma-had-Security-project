import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:perizinan_santri/Views/HomeKeamanan.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // home: const TestFirestoreScreen(),
      // debugShowCheckedModeBanner: false,
      home: const HomeKeamanan(),
      debugShowCheckedModeBanner: false,
    );
  }
}
