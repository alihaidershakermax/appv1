import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../../subscription/data/models/subscription_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in');
      }

      final userModel = await _getOrCreateUserDocument(userCredential.user!);
      await _updateLastSignIn(userModel.id);
      
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('Failed to create user');
      }

      // Update display name if provided
      if (displayName != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      final userModel = await _createUserDocument(userCredential.user!);
      
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      final userModel = await _getOrCreateUserDocument(userCredential.user!);
      await _updateLastSignIn(userModel.id);
      
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _getOrCreateUserDocument(firebaseUser);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException('No user logged in');
      }

      if (displayName != null) {
        await firebaseUser.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      await firebaseUser.reload();
      
      return await _getOrCreateUserDocument(_firebaseAuth.currentUser!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _getOrCreateUserDocument(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  Future<UserModel> _getOrCreateUserDocument(firebase_auth.User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      return UserModel.fromFirestore(docSnapshot, null);
    } else {
      return await _createUserDocument(firebaseUser);
    }
  }

  Future<UserModel> _createUserDocument(firebase_auth.User firebaseUser) async {
    final now = DateTime.now();
    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: now,
      lastSignIn: now,
      subscriptionPlan: SubscriptionPlan.free,
      dailyMessageCount: 0,
      lastMessageDate: now,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  Future<void> _updateLastSignIn(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'lastSignIn': Timestamp.now()});
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}