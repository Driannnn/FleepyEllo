import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _fa = FirebaseAuth.instance;

  // ---- Email/Password ----
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _fa.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _fa.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
      await cred.user?.reload();
    }
    return cred;
  }

  // ---- Google Sign-In ----
  Future<UserCredential> signInWithGoogle({
    required String webClientId, // default_web_client_id
  }) async {
    final google = GoogleSignIn(
      clientId: webClientId,
      scopes: const ['email', 'profile'],
    );
    final gUser = await google.signIn();
    if (gUser == null) {
      throw FirebaseAuthException(code: 'canceled', message: 'Login dibatalkan');
    }
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );
    return _fa.signInWithCredential(credential);
  }

  // ---- Utils ----
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _fa.signOut();
  }

  User? get currentUser => _fa.currentUser;
}

String friendlyError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-not-found':
      return 'Akun tidak ditemukan.';
    case 'wrong-password':
      return 'Password salah.';
    case 'user-disabled':
      return 'Akun dinonaktifkan.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar.';
    case 'weak-password':
      return 'Password terlalu lemah (min. 6 karakter).';
    case 'canceled':
      return 'Login dibatalkan.';
    case 'network-request-failed':
      return 'Masalah jaringan. Coba lagi.';
    case 'operation-not-allowed':
      return 'Metode login belum diaktifkan.';
    default:
      return 'Gagal: ${e.message ?? e.code}';
  }
}
