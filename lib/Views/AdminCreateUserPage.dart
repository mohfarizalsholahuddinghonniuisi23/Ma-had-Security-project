import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateUserPage extends StatelessWidget {
  const AdminCreateUserPage({Key? key}) : super(key: key);

  Future<void> createOrUpdateUser(BuildContext context, String email, String password, String role, String name) async {
    try {
      UserCredential credential;
      
      try {
        // Coba buat akun baru
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Akun baru dibuat: $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Akun sudah ada, coba login
          print('ℹ️ Akun sudah ada, mencoba login...');
          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Login berhasil: $email');
        } else {
          rethrow;
        }
      } catch (e) {
        // Handle untuk Flutter Web
        String errorString = e.toString().toLowerCase();
        if (errorString.contains('email-already-in-use')) {
          print('ℹ️ Akun sudah ada (web), mencoba login...');
          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Login berhasil: $email');
        } else {
          rethrow;
        }
      }

      // Simpan/update data role di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Role "$role" disimpan untuk $email');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $role berhasil dibuat/diupdate!'),
          backgroundColor: Colors.green,
        ),
      );

      // Logout setelah selesai
      await FirebaseAuth.instance.signOut();

    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Create User'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Buat atau Update Akun',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik tombol untuk membuat akun atau update role',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await createOrUpdateUser(
                  context,
                  'keamanan@mahad.com',
                  'keamanan123',
                  'keamanan',
                  'Admin Keamanan',
                );
              },
              icon: const Icon(Icons.security),
              label: const Text('Buat User Keamanan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await createOrUpdateUser(
                  context,
                  'pengurus@mahad.com',
                  'pengurus123',
                  'pengurus',
                  'Admin Pengurus',
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Buat User Pengurus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Akun:\n• keamanan@mahad.com / keamanan123\n• pengurus@mahad.com / pengurus123',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
