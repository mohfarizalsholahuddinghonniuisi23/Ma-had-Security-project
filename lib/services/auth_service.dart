import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Koneksi ke Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════
  //  STREAM: Pantau status login secara REALTIME
  // ═══════════════════════════════════════════════════════════
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ═══════════════════════════════════════════════════════════
  // GET CURRENT USER: Siapa yang sedang login?
  // ═══════════════════════════════════════════════════════════
  User? get currentUser => _auth.currentUser;

  // ═══════════════════════════════════════════════════════════
  // LOGIN: Masuk dengan Email & Password
  // ═══════════════════════════════════════════════════════════
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {


    try {
      // Minta Firebase untuk cek email & password
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );



      return credential;
    } on FirebaseAuthException catch (e) {


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
    } catch (e) {
      // Tangkap error lainnya (untuk Flutter Web)


      String errorString = e.toString().toLowerCase();

      // Parse error message untuk Flutter Web
      if (errorString.contains('user-not-found')) {
        throw Exception('Email tidak terdaftar');
      } else if (errorString.contains('wrong-password')) {
        throw Exception('Password salah');
      } else if (errorString.contains('invalid-credential')) {
        throw Exception('Email atau password salah');
      } else if (errorString.contains('invalid-email')) {
        throw Exception('Format email tidak valid');
      } else if (errorString.contains('network')) {
        throw Exception('Tidak ada koneksi internet');
      } else {
        throw Exception('Login gagal. Periksa email dan password Anda.');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REGISTER: Daftar Akun Baru
  // ═══════════════════════════════════════════════════════════
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {


    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );



      return credential;
    } on FirebaseAuthException catch (e) {


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
  // LOGOUT: Keluar dari Aplikasi
  // ═══════════════════════════════════════════════════════════
  Future<void> logout() async {


    await _auth.signOut();


  }
}
