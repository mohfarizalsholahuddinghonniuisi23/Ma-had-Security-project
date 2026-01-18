# 🕌 Aplikasi Perizinan Santri (Ma'had Security System)

Aplikasi mobile berbasis Flutter yang dirancang untuk mendigitalkan proses perizinan keluar-masuk santri di lingkungan Ma'had (Pondok Pesantren). Sistem ini memfasilitasi komunikasi data antara Pihak Keamanan (Security) dan Pengurus Ma'had.

## 🌟 Fitur Utama

Sistem ini memiliki dua aktor utama dengan hak akses yang berbeda:

### 1. 🛡️ Role Keamanan (Security)
Petugas keamanan bertugas sebagai garda depan pencatatan keluar-masuk santri.
*   **Login Khusus**: Akses menggunakan akun dengan email yang mengandung kata `keamanan`.
*   **Input Izin Pulang**: Mencatat santri yang izin keluar.
    *   Mengisi data: Nama, NIS, Alamat, No. Telp Wali, Alasan.
    *   **Bukti Foto**: Mengambil foto santri secara realtime menggunakan kamera.
    *   **Auto-Approval**: Data yang diinput otomatis berstatus "Disetujui" agar santri bisa langsung keluar.
*   **Monitoring Izin Aktif**: Melihat daftar santri yang saat ini sedang berada di luar pondok.
*   **Verifikasi Kembali**: Menekan tombol verifikasi saat santri kembali ke pondok. Data akan berpindah ke riwayat dan status santri menjadi "Di Ma'had".
*   **Notifikasi Keterlambatan**: Penanda visual (Warna Merah) jika santri kembali melebihi tanggal yang dijanjikan.

### 2. 👤 Role Pengurus (Admin)
Pengurus bertugas untuk memonitor aktivitas perizinan.
*   **Login Khusus**: Akses menggunakan akun dengan email yang mengandung kata `pengurus`.
*   **Dashboard Monitoring**: Melihat seluruh daftar perizinan, baik yang sedang berlangsung maupun riwayat.
*   **View-Only Access**: Pengurus hanya dapat melihat data dan detail (termasuk foto bukti) tanpa melakukan perubahan data, memastikan integritas data lapangan yang diinput keamanan.

---

## 🛠️ Teknologi & Arsitektur

### Tech Stack
*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Backend & Database**: [Firebase](https://firebase.google.com/)
    *   **Authentication**: Manajemen sesi pengguna (Email/Password).
    *   **Cloud Firestore**: Database NoSQL realtime untuk menyimpan data perizinan.
*   **Media**: Penyimpanan foto menggunakan format Base64 string yang disimpan langsung di dokumen Firestore (Dioptimalkan dengan kompresi).

### Struktur Folder Penting
*   `lib/Views`: Antarmuka Pengguna (UI).
    *   `Login.dart`: Halaman masuk.
    *   `HomeKeamanan.dart`: Dashboard utama keamanan (Tab Izin Aktif & Riwayat).
    *   `HomePengurus.dart`: Dashboard monitoring pengurus.
    *   `FormIzinPulang.dart`: Form input data izin.
*   `lib/services`: Layer logika bisnis.
    *   `auth_service.dart`: Menangani login/logout Firebase Auth.
    *   `izin_service.dart`: Menangani CRUD (Create, Read, Update) ke Firestore.
*   `lib/models`: Definisi struktur data (`IzinPulang`, dll).

---

## 🚀 Panduan Instalasi & Menjalankan

### Prasyarat
1.  **Flutter SDK** terinstal di komputer ([Panduan Install](https://docs.flutter.dev/get-started/install)).
2.  **Akun Firebase** dan file konfigurasi (`google-services.json` untuk Android / `GoogleService-Info.plist` untuk iOS / `firebase_options.dart` untuk Web/All).

### Langkah-langkah
1.  **Clone Project**
    ```bash
    git clone [repository_url]
    cd [nama_folder_project]
    ```

2.  **Install Library**
    Download semua dependency yang dibutuhkan:
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase**
    Pastikan konfigurasi Firebase sudah sesuai dengan bundle ID aplikasi. Jika menggunakan FlutterFire CLI:
    ```bash
    flutterfire configure
    ```

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

---

## 📝 Catatan Penggunaan (User Guide)

### Cara Membuat Akun (Simulasi)
Sistem membedakan role berdasarkan **Email**:
*   Untuk login sebagai **Keamanan**: Buat user di Firebase Auth dengan email misal `pos1.keamanan@mahad.com`.
*   Untuk login sebagai **Pengurus**: Buat user di Firebase Auth dengan email misal `admin.pengurus@mahad.com`.

### Alur Kerja (Workflow)
1.  **Keamanan** login -> Klik tombol **(+)** atau "Buat Izin".
2.  Isi form & ambil foto -> Klik **Simpan**.
3.  Santri pergi (Status: *Disetujui*, Lokasi: *Pulang*).
4.  Saat santri balik -> **Keamanan** cari nama santri di dashboard -> Klik **Verifikasi Kembali**.
5.  Status berubah menjadi *Sudah Kembali* dan masuk ke menu Riwayat.

---
*Dibuat dengan ❤️ untuk kemudahan administrasi Ma'had.*
