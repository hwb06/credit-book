import 'package:firebase_auth/firebase_auth.dart';
import 'package:udhaar_app/data/data_sources/remote/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _service;

  AuthRepository({FirebaseAuthService? service})
      : _service = service ?? FirebaseAuthService();

  User? get currentUser => _service.currentUser;

  Stream<User?> get authStateChanges => _service.authStateChanges;

  Future<User> login(String email, String password) =>
      _service.login(email, password);

  Future<void> logout() => _service.logout();
}