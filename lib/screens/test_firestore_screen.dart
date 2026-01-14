import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestoreScreen extends StatelessWidget {
  const TestFirestoreScreen({Key?  key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Test Firestore'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance. collection('izin').snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color:  Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada data izin',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah data',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Data exists - show list
          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: snapshot. data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Text(
                      (data['namaSantri'] ??  'N')[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data['namaSantri'] ?? 'No name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:  Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Status: ${data['status'] ?? '-'}'),
                      Text('Angkatan: ${data['angkatan'] ?? '-'} • Kamar: ${data['noKamar'] ?? '-'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Konfirmasi hapus
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Hapus Data'),
                          content: Text('Yakin ingin menghapus data ini?'),
                          actions:  [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await doc.reference.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data berhasil dihapus')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
        onPressed: () async {
          // Test tambah data
          try {
            await FirebaseFirestore.instance.collection('izin').add({
              'namaSantri': 'Test User ${DateTime.now().second}',
              'angkatan': '2024',
              'noKamar': 'A-${DateTime.now().second}',
              'status': 'menunggu_pulang',
              'waktuInput': FieldValue. serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data berhasil ditambahkan! '),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}