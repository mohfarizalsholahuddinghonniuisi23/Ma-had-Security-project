import 'package:cloud_firestore/cloud_firestore.dart';

class IzinPulang {
  final String? id;
  final String namaSantri;
  final String nis;
  final String alamat;
  final String noTelpWali;
  final String alasan;
  final String status; // "Belum Disetujui" / "Disetujui"
  final String statusSantri; // "Pulang" / "Di Ma'had" - Status lokasi santri
  final DateTime tanggalPulang;
  final DateTime? tanggalKembali; // Rencana tanggal kembali
  final DateTime createdAt;

  // Field baru untuk verifikasi kembali
  final bool sudahKembali;
  final DateTime? tanggalVerifikasiKembali; // Tanggal aktual santri kembali
  final String?
      namaKeamananVerifikasi; // Nama keamanan yang memverifikasi kembali

  // Field untuk foto bukti
  final String? fotoBase64;

  // Field untuk nama keamanan yang mengizinkan pulang
  final String? namaKeamananIzin;

  IzinPulang({
    this.id,
    required this.namaSantri,
    required this.nis,
    required this.alamat,
    required this.noTelpWali,
    required this.alasan,
    this.status = 'Belum Disetujui',
    this.statusSantri = 'Pulang',
    required this.tanggalPulang,
    this.tanggalKembali,
    DateTime? createdAt,
    this.sudahKembali = false,
    this.tanggalVerifikasiKembali,
    this.namaKeamananVerifikasi,
    this.fotoBase64,
    this.namaKeamananIzin,
  }) : createdAt = createdAt ?? DateTime.now();

  // Cek apakah santri terlambat kembali
  bool isTerlambat() {
    if (tanggalKembali == null) return false;
    if (sudahKembali && tanggalVerifikasiKembali != null) {
      // Bandingkan tanggal verifikasi dengan rencana kembali
      return tanggalVerifikasiKembali!.isAfter(tanggalKembali!);
    }
    // Jika belum kembali, bandingkan dengan hari ini
    final now = DateTime.now();
    final batasKembali = DateTime(
      tanggalKembali!.year,
      tanggalKembali!.month,
      tanggalKembali!.day,
      23,
      59,
      59,
    );
    return now.isAfter(batasKembali);
  }

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
      statusSantri: data['statusSantri'] ?? 'Pulang',
      tanggalPulang: (data['tanggalPulang'] as Timestamp).toDate(),
      tanggalKembali: data['tanggalKembali'] != null
          ? (data['tanggalKembali'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      sudahKembali: data['sudahKembali'] ?? false,
      tanggalVerifikasiKembali: data['tanggalVerifikasiKembali'] != null
          ? (data['tanggalVerifikasiKembali'] as Timestamp).toDate()
          : null,
      namaKeamananVerifikasi: data['namaKeamananVerifikasi'],
      fotoBase64: data['fotoBase64'],
      namaKeamananIzin: data['namaKeamananIzin'],
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
      'statusSantri': statusSantri,
      'tanggalPulang': Timestamp.fromDate(tanggalPulang),
      'tanggalKembali':
          tanggalKembali != null ? Timestamp.fromDate(tanggalKembali!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'sudahKembali': sudahKembali,
      'tanggalVerifikasiKembali': tanggalVerifikasiKembali != null
          ? Timestamp.fromDate(tanggalVerifikasiKembali!)
          : null,
      'namaKeamananVerifikasi': namaKeamananVerifikasi,
      'fotoBase64': fotoBase64,
      'namaKeamananIzin': namaKeamananIzin,
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
    String? statusSantri,
    DateTime? tanggalPulang,
    DateTime? tanggalKembali,
    DateTime? createdAt,
    bool? sudahKembali,
    DateTime? tanggalVerifikasiKembali,
    String? namaKeamananVerifikasi,
    String? fotoBase64,
    String? namaKeamananIzin,
  }) {
    return IzinPulang(
      id: id ?? this.id,
      namaSantri: namaSantri ?? this.namaSantri,
      nis: nis ?? this.nis,
      alamat: alamat ?? this.alamat,
      noTelpWali: noTelpWali ?? this.noTelpWali,
      alasan: alasan ?? this.alasan,
      statusSantri: statusSantri ?? this.statusSantri,
      tanggalPulang: tanggalPulang ?? this.tanggalPulang,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      createdAt: createdAt ?? this.createdAt,
      sudahKembali: sudahKembali ?? this.sudahKembali,
      tanggalVerifikasiKembali:
          tanggalVerifikasiKembali ?? this.tanggalVerifikasiKembali,
      namaKeamananVerifikasi:
          namaKeamananVerifikasi ?? this.namaKeamananVerifikasi,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      namaKeamananIzin: namaKeamananIzin ?? this.namaKeamananIzin,
    );
  }

  @override
  String toString() {
    return 'IzinPulang(id: $id, namaSantri: $namaSantri, nis: $nis,  statusSantri: $statusSantri)';
  }
}
