import 'package:cloud_firestore/cloud_firestore.dart';

class IzinPulang {
  final String? id;
  final String namaSantri;
  final String nis;
  final String alamat;
  final String noTelpWali;
  final String alasan;
  final String status; // "Belum Disetujui" / "Disetujui"
  final DateTime tanggalPulang;
  final DateTime? tanggalKembali;
  final DateTime createdAt;

  IzinPulang({
    this.id,
    required this.namaSantri,
    required this.nis,
    required this.alamat,
    required this.noTelpWali,
    required this.alasan,
    this.status = 'Belum Disetujui',
    required this.tanggalPulang,
    this.tanggalKembali,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert dari Firestore Document ke Object
  factory IzinPulang.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IzinPulang(
      id: doc.id,
      namaSantri: data['namaSantri'] ?? '',
      nis: data['nis'] ?? '',
      alamat: data['alamat'] ?? '',
      noTelpWali: data['noTelpWali'] ?? '',
      alasan: data['alasan'] ?? '',
      status: data['status'] ?? 'Belum Disetujui',
      tanggalPulang: (data['tanggalPulang'] as Timestamp).toDate(),
      tanggalKembali: data['tanggalKembali'] != null
          ? (data['tanggalKembali'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert dari Object ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'namaSantri': namaSantri,
      'nis': nis,
      'alamat': alamat,
      'noTelpWali': noTelpWali,
      'alasan': alasan,
      'status': status,
      'tanggalPulang': Timestamp.fromDate(tanggalPulang),
      'tanggalKembali':
          tanggalKembali != null ? Timestamp.fromDate(tanggalKembali!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy dengan perubahan tertentu
  IzinPulang copyWith({
    String? id,
    String? namaSantri,
    String? nis,
    String? alamat,
    String? noTelpWali,
    String? alasan,
    String? status,
    DateTime? tanggalPulang,
    DateTime? tanggalKembali,
    DateTime? createdAt,
  }) {
    return IzinPulang(
      id: id ?? this.id,
      namaSantri: namaSantri ?? this.namaSantri,
      nis: nis ?? this.nis,
      alamat: alamat ?? this.alamat,
      noTelpWali: noTelpWali ?? this.noTelpWali,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      tanggalPulang: tanggalPulang ?? this.tanggalPulang,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'IzinPulang(id: $id, namaSantri: $namaSantri, nis: $nis, status: $status)';
  }
}
