import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/izin_pulang.dart';

class IzinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'izin_pulang';

  // CREATE - Tambah izin pulang baru
  Future<String> tambahIzinPulang(IzinPulang izin) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(_collection).add(izin.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah izin: $e');
    }
  }

  // READ - Stream semua izin pulang (realtime)
  Stream<List<IzinPulang>> getSemuaIzinPulang() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IzinPulang.fromFirestore(doc)).toList());
  }

  // READ - Stream izin berdasarkan status
  Stream<List<IzinPulang>> getIzinByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IzinPulang.fromFirestore(doc)).toList());
  }

  // READ - Get single izin by ID
  Future<IzinPulang?> getIzinPulangById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return IzinPulang.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data izin: $e');
    }
  }

  // UPDATE - Update seluruh data izin
  Future<void> updateIzinPulang(IzinPulang izin) async {
    if (izin.id == null) {
      throw Exception('ID izin tidak boleh null');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(izin.id)
          .update(izin.toFirestore());
    } catch (e) {
      throw Exception('Gagal update izin: $e');
    }
  }

  // UPDATE - Update status izin saja
  Future<void> updateStatusIzin(String id, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'status': status});
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  // UPDATE - Set tanggal kembali (untuk izin kembali)
  Future<void> setTanggalKembali(String id, DateTime tanggalKembali) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'tanggalKembali': Timestamp.fromDate(tanggalKembali),
      });
    } catch (e) {
      throw Exception('Gagal set tanggal kembali: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VERIFIKASI KEMBALI - Konfirmasi santri sudah kembali
  // ═══════════════════════════════════════════════════════════
  Future<void> verifikasiKembali(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'sudahKembali': true,
        'tanggalVerifikasiKembali': Timestamp.fromDate(DateTime.now()),
        'statusSantri': "Di Ma'had",
      });

    } catch (e) {
      throw Exception('Gagal verifikasi kembali: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET IZIN AKTIF - Izin yang disetujui & belum kembali
  // ═══════════════════════════════════════════════════════════
  Stream<List<IzinPulang>> getIzinAktif() {
    // Simple query tanpa composite index - filter di app
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IzinPulang.fromFirestore(doc))
              .where((izin) => (izin.status == 'Disetujui' || izin.status == 'Belum Disetujui') && !izin.sudahKembali)
              .toList();
        });
  }

  // ═══════════════════════════════════════════════════════════
  // GET RIWAYAT IZIN - Izin yang sudah selesai (sudah kembali)
  // ═══════════════════════════════════════════════════════════
  Stream<List<IzinPulang>> getRiwayatIzin() {
    // Simple query tanpa composite index - filter di app
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IzinPulang.fromFirestore(doc))
              .where((izin) => izin.sudahKembali)
              .toList();
        });
  }

  // DELETE - Hapus izin
  Future<void> hapusIzinPulang(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal hapus izin: $e');
    }
  }

  // READ - Search izin by NIS
  Stream<List<IzinPulang>> searchByNis(String nis) {
    return _firestore
        .collection(_collection)
        .where('nis', isEqualTo: nis)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IzinPulang.fromFirestore(doc)).toList());
  }

  // READ - Get izin yang belum kembali
  Stream<List<IzinPulang>> getIzinBelumKembali() {
    // Simple query tanpa composite index - filter di app
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IzinPulang.fromFirestore(doc))
              .where((izin) => izin.status == 'Disetujui' && !izin.sudahKembali)
              .toList();
        });
  }
}
