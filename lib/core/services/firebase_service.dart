import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email and Password Registration
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    String? middleName,
    required String lastName,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user
      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await _storeUserData(
          userId: user.uid,
          email: email,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
        );

        // Send email verification
        await user.sendEmailVerification();

        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Email and Password Login
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Sign out first to clear any cached credentials
      await _googleSignIn.signOut();
      
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain authentication details with fresh token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Verify we have valid tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain valid authentication tokens');
      }

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Create new user document if it doesn't exist
          await _storeUserData(
            userId: user.uid,
            email: user.email ?? '',
            firstName: user.displayName?.split(' ').first ?? '',
            lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
            profilePictureUrl: user.photoURL,
          );
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Sign out on authentication failure to clear state
      await _googleSignIn.signOut();
      throw _handleAuthException(e);
    } catch (e) {
      // Sign out on any failure to clear state
      await _googleSignIn.signOut();
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Store user data in Firestore
  Future<void> _storeUserData({
    required String userId,
    required String email,
    required String firstName,
    String? middleName,
    required String lastName,
    String? profilePictureUrl,
  }) async {
    try {
      Map<String, dynamic> userData = {
        'email': email,
        'first_name': firstName,
        'middle_name': middleName ?? '',
        'last_name': lastName,
        'isAdmin': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      // Add profile picture URL if available
      if (profilePictureUrl != null) {
        userData['profile_picture_url'] = profilePictureUrl;
      }
      
      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      throw Exception('Error storing user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData({
    required String userId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? profilePictureUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (firstName != null) {
        updateData['first_name'] = firstName;
      }

      if (middleName != null) {
        updateData['middle_name'] = middleName;
      }

      if (lastName != null) {
        updateData['last_name'] = lastName;
      }
      
      if (profilePictureUrl != null) {
        updateData['profile_picture_url'] = profilePictureUrl;
      }

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Error updating user data: $e');
    }
  }

  // Get user data from Firestore as UserModel
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>, userId);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user data: $e');
    }
  }

  // Get current user as UserModel
  Future<UserModel?> getCurrentUserModel() async {
    try {
      User? user = currentUser;
      if (user != null) {
        UserModel? userModel = await getUserData(user.uid);
        
        // If user exists but no profile picture in Firestore, and user has Google photo URL
        if (userModel != null && userModel.profilePictureUrl == null && user.photoURL != null) {
          await updateUserData(
            userId: user.uid,
            profilePictureUrl: user.photoURL,
          );
          // Get updated user model
          userModel = await getUserData(user.uid);
        }
        
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting current user model: $e');
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  // Re-authenticate with email and password
  Future<void> reauthenticateWithEmailPassword(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user is currently signed in');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  // Re-authenticate with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      // Sign out first to force account selection
      await _googleSignIn.signOut();
      
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain valid authentication tokens');
      }

      // Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Re-authenticate
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      await _googleSignIn.signOut();
      throw _handleAuthException(e);
    } catch (e) {
      await _googleSignIn.signOut();
      throw Exception('Re-authentication failed: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Check if user signed in with Google and disconnect
        if (user.providerData.any((userInfo) => userInfo.providerId == 'google.com')) {
          await _googleSignIn.signOut();
        }
        
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }

  // Get user's sign-in method
  String? getUserSignInMethod() {
    User? user = _auth.currentUser;
    if (user == null) return null;

    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'google.com') {
        return 'google';
      } else if (userInfo.providerId == 'password') {
        return 'password';
      }
    }
    return null;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please use a different email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'Authentication failed. Please try signing in again.';
      case 'requires-recent-login':
        return 'REQUIRES_REAUTH'; // Special marker for re-authentication
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
