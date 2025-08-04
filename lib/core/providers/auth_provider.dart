import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _firebaseInitialized = false;
  String? _userName;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  void _initializeAuth() async {
    try {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen(_onAuthStateChanged);
      _firebaseInitialized = true;
      print('Firebase Auth initialized successfully');
      
      // Check for saved login state
      await _checkSavedLoginState();
    } catch (e) {
      print('Firebase Auth initialization failed: $e');
      _firebaseInitialized = false;
      // Start with unauthenticated state for demo purposes
      _state = AuthState.unauthenticated;
      // Check for saved login state even if Firebase fails
      await _checkSavedLoginState();
      // Notify listeners immediately so the app can proceed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  Future<void> _checkSavedLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedName = prefs.getString('user_name');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn && savedEmail != null) {
        _userName = savedName;
        // Create a mock user for demo purposes if Firebase is not available
        if (!_firebaseInitialized) {
          _state = AuthState.authenticated;
          notifyListeners();
        }
        print('Restored login state for: $savedEmail');
      }
    } catch (e) {
      print('Error checking saved login state: $e');
    }
  }
  
  Future<void> _saveLoginState(String email, String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      if (name != null) {
        await prefs.setString('user_name', name);
      }
      await prefs.setBool('is_logged_in', true);
      _userName = name;
    } catch (e) {
      print('Error saving login state: $e');
    }
  }
  
  Future<void> _clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.setBool('is_logged_in', false);
      _userName = null;
    } catch (e) {
      print('Error clearing login state: $e');
    }
  }
  
  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  bool get isAuthenticated => _user != null && _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  
  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();
      
      if (!_firebaseInitialized || _auth == null) {
        // For demo purposes, allow any email/password combination when Firebase is not available
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        if (email.isNotEmpty && password.isNotEmpty) {
          _state = AuthState.authenticated;
          await _saveLoginState(email.trim(), null);
          notifyListeners();
          return true;
        } else {
          _state = AuthState.error;
          _errorMessage = 'Please enter valid email and password.';
          notifyListeners();
          return false;
        }
      }
      
      final UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        _user = result.user;
        _state = AuthState.authenticated;
        await _saveLoginState(email.trim(), null);
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during login: ${e.code} - ${e.message}');
      _state = AuthState.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error during login: $e');
      _state = AuthState.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> createUserWithEmailAndPassword(String email, String password, [String? name]) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();
      
      if (!_firebaseInitialized || _auth == null) {
        // For demo purposes, allow any email/password combination when Firebase is not available
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        if (email.isNotEmpty && password.isNotEmpty) {
          _state = AuthState.authenticated;
          await _saveLoginState(email.trim(), name);
          notifyListeners();
          return true;
        } else {
          _state = AuthState.error;
          _errorMessage = 'Please enter valid email and password.';
          notifyListeners();
          return false;
        }
      }
      
      final UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        _user = result.user;
        _state = AuthState.authenticated;
        await _saveLoginState(email.trim(), name);
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during signup: ${e.code} - ${e.message}');
      _state = AuthState.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error during signup: $e');
      _state = AuthState.error;
      _errorMessage = 'Signup failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      if (!_firebaseInitialized || _auth == null) {
        // For demo purposes, simulate password reset success when Firebase is not available
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        return true;
      }
      
      await _auth!.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error during password reset: $e');
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      if (_firebaseInitialized && _auth != null) {
        await _auth!.signOut();
      }
      await _clearLoginState();
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out. Please try again.';
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  String _getErrorMessage(String errorCode) {
    print('Firebase Auth Error Code: $errorCode');
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'missing-email':
        return 'Please enter your email address.';
      case 'missing-password':
        return 'Please enter your password.';
      default:
        print('Unhandled Firebase Auth error code: $errorCode');
        return 'Authentication error: $errorCode. Please try again.';
    }
  }
}