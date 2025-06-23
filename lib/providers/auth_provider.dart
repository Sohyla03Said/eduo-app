import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get userRole => _userModel?.role.toString().split('.').last; // Adjusted for current UserModel
  Map<String, dynamic>? get userData => _userModel?.toMap(); // Changed to toMap
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _userModel != null;
  bool get isStudent => _userModel?.role == UserRole.student;
  bool get isTeacher => _userModel?.role == UserRole.teacher;
  bool get isAdmin => _userModel?.role == UserRole.admin;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _loadUserData();
    }
    _auth.authStateChanges().listen((User? user) async {
      if (_user != user) {
        _user = user;
        if (user != null) {
          await _loadUserData();
        } else {
          _userModel = null;
        }
        notifyListeners();
      }
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(fullName);

      await _createUserDocument(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        role: role,
      );

      await _loadUserData();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Google sign in was cancelled');
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          fullName: userCredential.user!.displayName ?? 'User',
          role: UserRole.student,
        );
      }

      await _loadUserData();
      return true;
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      _user = null;
      _userModel = null;
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      await prefs.remove('userId');

      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
    required UserRole role,
  }) async {
    final userModel = UserModel(
      uid: uid,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(), // Simplified to match UserModel
    );

    await _firestore.collection('users').doc(uid).set(userModel.toMap());
  }

  Future<void> _loadUserData() async {
    if (_auth.currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (doc.exists) {
          _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          _user = _auth.currentUser;
        } else {
          _setError('User data not found in Firestore');
        }
        notifyListeners();
      } catch (e) {
        _setError('Error loading user data: ${e.toString()}');
      }
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? institution,
    String? profileImageUrl,
  }) async {
    try {
      if (_user == null || _userModel == null) {
        _setError('User not authenticated');
        return false;
      }

      _setLoading(true);
      _setError(null);

      Map<String, dynamic> updates = {};
      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (institution != null) updates['institution'] = institution;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      updates['updatedAt'] = DateTime.now().millisecondsSinceEpoch; // Match UserModel format

      await _firestore.collection('users').doc(_user!.uid).update(updates);

      if (fullName != null) {
        await _user!.updateDisplayName(fullName);
      }

      await _loadUserData();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthError(e));
      return false;
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to send verification email: ${e.toString()}');
      return false;
    }
  }

  Future<void> reloadUser() async {
    if (_user != null) {
      await _user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _setError(null);

      await _firestore.collection('users').doc(_user!.uid).delete();
      await _user!.delete();

      _user = null;
      _userModel = null;

      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }
}