import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // =========================
  // REGISTER
  // =========================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user?.updateDisplayName(name);
      await cred.user?.sendEmailVerification();

      _status = AuthStatus.emailNotVerified;
      _firebaseUser = cred.user;

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // =========================
  // LOGIN EMAIL
  // =========================
  Future<bool> loginEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = cred.user;

      if (!cred.user!.emailVerified) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // =========================
  // LOGIN GOOGLE
  // =========================
  Future<bool> loginGoogle() async {
    try {
      _setLoading();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError("Login dibatalkan");
        return false;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      _firebaseUser = cred.user;
      _status = AuthStatus.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // =========================
  // CHECK EMAIL VERIFIED
  // =========================
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    return false;
  }

  // =========================
  // RESEND EMAIL
  // =========================
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    _firebaseUser = null;
    _backendToken = null;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  // =========================
  // HELPER
  // =========================
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String? msg) {
    _status = AuthStatus.error;
    _errorMessage = msg ?? "Terjadi kesalahan";
    notifyListeners();
  }
}