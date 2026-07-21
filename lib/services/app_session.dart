import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_role.dart';
import 'firestore_paths.dart';


class AppSession extends ChangeNotifier {
  AppSession._internal() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  static final AppSession instance = AppSession._internal();

  static String emailFor(String username) =>
      '${username.trim().toLowerCase()}@pursemaison.app';

  StreamSubscription<User?>? _authSub;

  UserRole? _currentRole;
  String? _username;
  bool _isInitializing = true;

  UserRole? get currentRole => _currentRole;
  String? get username => _username;
  bool get isLoggedIn => _currentRole != null;

  bool get isInitializing => _isInitializing;

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _currentRole = null;
      _username = null;
      _isInitializing = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data == null) {
        _currentRole = null;
        _username = null;
      } else {
        _currentRole = UserRole.values.byName(data['role'] as String);
        _username = data['username'] as String? ?? user.email;
      }
    } catch (_) {
      _currentRole = null;
      _username = null;
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<String?> authenticate(String username, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailFor(username),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Invalid username or password';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Login failed: ${e.message}';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
