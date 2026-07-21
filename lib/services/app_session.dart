import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_role.dart';
import 'firestore_paths.dart';

/// Tracks who's currently logged in, backed by real Firebase Authentication
/// + a `users/{uid}` Firestore doc that stores the account's role.
///
/// A single app-wide instance (AppSession.instance) so RouteGuard, the
/// sidebar, and any page can all check the current role without threading
/// it through constructors — same shape as before, just backed by Firebase
/// instead of MockAccounts.
///
/// Login screens use usernames, not emails, so each username is mapped to
/// a synthetic email of the form `<username>@pursemaison.app` for Firebase
/// Auth's email/password sign-in. The Firestore `users/{uid}` doc stores
/// the real username + role so the rest of the app never has to know
/// about the synthetic email.
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

  /// True until the very first auth-state event (app cold start) has been
  /// resolved, including fetching the role doc if someone's already
  /// signed in. RouteGuard shows a loading spinner instead of redirecting
  /// to /login while this is true, so a returning logged-in user doesn't
  /// flash the login page.
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
        // Signed in with Firebase Auth but has no role doc — treat as
        // logged out rather than letting them into the app with no role.
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

  /// Signs in with [username]/[password] against Firebase Auth. Returns
  /// null on success (session updates via the authStateChanges listener
  /// above), or a human-readable error message on failure.
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
