import 'package:firebase_auth/firebase_auth.dart';

/// AuthService adalah "Koki" yang mengurus semua hal tentang Login/Logout
/// Seperti satpam di pintu masuk gedung yang cek siapa yang boleh masuk
class AuthService {
  // Koneksi ke Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════
  // 📡 STREAM: Pantau status login secara REALTIME
  // ═══════════════════════════════════════════════════════════
  // Seperti CCTV yang selalu memantau siapa yang sedang login
  // Kalau ada perubahan (login/logout), langsung ketahuan!
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ═══════════════════════════════════════════════════════════
  // 👤 GET CURRENT USER: Siapa yang sedang login?
  // ═══════════════════════════════════════════════════════════
  User? get currentUser => _auth.currentUser;

  // ═══════════════════════════════════════════════════════════
  // 🔐 LOGIN: Masuk dengan Email & Password
  // ═══════════════════════════════════════════════════════════
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔐 AUTH SERVICE: Proses Login');
    print('═══════════════════════════════════════════════════════════');
    print('📧 Email: $email');
    print('🔑 Password: ${'*' * password.length}');
    print('');
    print('⏳ Menghubungi Firebase Auth...');

    try {
      // Minta Firebase untuk cek email & password
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login berhasil!');
      print('👤 User ID: ${credential.user?.uid}');
      print('📧 Email: ${credential.user?.email}');
      print('═══════════════════════════════════════════════════════════');

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Login gagal: ${e.message}');
      print('═══════════════════════════════════════════════════════════');

      // Terjemahkan pesan error ke Bahasa Indonesia
      String pesanError;
      switch (e.code) {
        case 'user-not-found':
          pesanError = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          pesanError = 'Password salah';
          break;
        case 'invalid-email':
          pesanError = 'Format email tidak valid';
          break;
        case 'user-disabled':
          pesanError = 'Akun telah dinonaktifkan';
          break;
        case 'invalid-credential':
          pesanError = 'Email atau password salah';
          break;
        default:
          pesanError = e.message ?? 'Terjadi kesalahan';
      }
      throw Exception(pesanError);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📝 REGISTER: Daftar Akun Baru
  // ═══════════════════════════════════════════════════════════
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 AUTH SERVICE: Proses Register');
    print('═══════════════════════════════════════════════════════════');
    print('📧 Email: $email');
    print('');
    print('⏳ Mendaftarkan akun baru...');

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Register berhasil!');
      print('👤 User ID: ${credential.user?.uid}');
      print('═══════════════════════════════════════════════════════════');

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Register gagal: ${e.message}');

      String pesanError;
      switch (e.code) {
        case 'weak-password':
          pesanError = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'email-already-in-use':
          pesanError = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          pesanError = 'Format email tidak valid';
          break;
        default:
          pesanError = e.message ?? 'Terjadi kesalahan';
      }
      throw Exception(pesanError);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🚪 LOGOUT: Keluar dari Aplikasi
  // ═══════════════════════════════════════════════════════════
  Future<void> logout() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚪 AUTH SERVICE: Proses Logout');
    print('═══════════════════════════════════════════════════════════');
    print('👤 User: ${_auth.currentUser?.email}');
    print('⏳ Melakukan logout...');

    await _auth.signOut();

    print('✅ Logout berhasil!');
    print('═══════════════════════════════════════════════════════════');
  }
}
