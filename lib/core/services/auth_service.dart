import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  User? get currentUser => _firebaseService.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isEmailVerified => _firebaseService.isEmailVerified();
  
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;

  // Email and Password Registration
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    String? middleName,
    required String lastName,
  }) async {
    try {
      await _firebaseService.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
      );
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Email and Password Login
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      await _firebaseService.signInWithGoogle();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get user data from Firestore as UserModel
  Future<UserModel?> getUserData(String userId) async {
    try {
      return await _firebaseService.getUserData(userId);
    } catch (e) {
      throw Exception('Error getting user data: $e');
    }
  }

  // Get current user as UserModel
  Future<UserModel?> getCurrentUserModel() async {
    try {
      return await _firebaseService.getCurrentUserModel();
    } catch (e) {
      throw Exception('Error getting current user model: $e');
    }
  }

  // Update User Data
  Future<void> updateUserData({
    String? firstName,
    String? middleName,
    String? lastName,
    String? profilePictureUrl,
  }) async {
    try {
      if (currentUser != null) {
        await _firebaseService.updateUserData(
          userId: currentUser!.uid,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          profilePictureUrl: profilePictureUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Update Profile Picture
  Future<void> updateProfilePicture(String profilePictureUrl) async {
    try {
      if (currentUser != null) {
        await _firebaseService.updateUserData(
          userId: currentUser!.uid,
          profilePictureUrl: profilePictureUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Re-authenticate with email and password
  Future<void> reauthenticateWithEmailPassword(String password) async {
    try {
      await _firebaseService.reauthenticateWithEmailPassword(password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Re-authenticate with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      await _firebaseService.reauthenticateWithGoogle();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get user's sign-in method
  String? getUserSignInMethod() {
    return _firebaseService.getUserSignInMethod();
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _firebaseService.deleteAccount();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
