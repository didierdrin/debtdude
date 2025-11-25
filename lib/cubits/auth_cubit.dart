// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   AuthCubit() : super(AuthInitial());
  
//   // Removed _configureAuth() as it was conflicting with App Check

//   Future<void> signUp(String email, String password, String confirmPassword) async {
//     if (password != confirmPassword) {
//       emit(AuthError('Passwords do not match'));
//       return;
//     }

//     emit(AuthLoading());
    
//     try {
//       final UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
      
//       if (result.user != null) {
//         emit(AuthSuccess('Sign up successful'));
//       } else {
//         emit(AuthError('Sign up failed'));
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'weak-password':
//           errorMessage = 'The password is too weak';
//           break;
//         case 'email-already-in-use':
//           errorMessage = 'An account already exists for this email';
//           break;
//         case 'invalid-email':
//           errorMessage = 'The email address is invalid';
//           break;
//         default:
//           errorMessage = e.message ?? 'Sign up failed';
//       }
//       emit(AuthError(errorMessage));
//     } catch (e) {
//       emit(AuthError('An unexpected error occurred'));
//     }
//   }

//   Future<void> signIn(String email, String password) async {
//     emit(AuthLoading());
    
//     try {
//       final UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
      
//       if (result.user != null) {
//         emit(AuthSuccess('Sign in successful'));
//       } else {
//         emit(AuthError('Sign in failed'));
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found with this email';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Incorrect password';
//           break;
//         case 'invalid-email':
//           errorMessage = 'The email address is invalid';
//           break;
//         case 'user-disabled':
//           errorMessage = 'This account has been disabled';
//           break;
//         default:
//           errorMessage = e.message ?? 'Sign in failed';
//       }
//       emit(AuthError(errorMessage));
//     } catch (e) {
//       emit(AuthError('An unexpected error occurred'));
//     }
//   }
// }

// abstract class AuthState {}

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class AuthSuccess extends AuthState {
//   final String message;
//   AuthSuccess(this.message);
// }

// class AuthError extends AuthState {
//   final String message;
//   AuthError(this.message);
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthCubit() : super(AuthInitial()) {
    _configureAuth();
  }

  void _configureAuth() {
    _auth.setSettings(
      appVerificationDisabledForTesting: true,
      forceRecaptchaFlow: false,
    );
  }

  Future<void> signUp(String email, String password, String confirmPassword) async {
    if (email.trim().isEmpty) {
      emit(AuthError('Please enter your email address'));
      return;
    }
    if (password.isEmpty) {
      emit(AuthError('Please enter a password'));
      return;
    }
    if (password != confirmPassword) {
      emit(AuthError('Passwords do not match. Please try again'));
      return;
    }
    
    emit(AuthLoading());
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      if (result.user != null) {
        emit(AuthSuccess('Welcome! Your account has been created successfully'));
      } else {
        emit(AuthError('We encountered an issue creating your account. Please try again'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Please choose a stronger password with at least 6 characters';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please sign in or use a different email';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        default:
          errorMessage = 'We encountered an issue creating your account. Please try again';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('Something went wrong. Please check your connection and try again'));
    }
  }

  Future<void> signIn(String email, String password) async {
    if (email.trim().isEmpty) {
      emit(AuthError('Please enter your email address'));
      return;
    }
    if (password.isEmpty) {
      emit(AuthError('Please enter your password'));
      return;
    }
    
    emit(AuthLoading());
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      if (result.user != null) {
        emit(AuthSuccess('Welcome back! You have signed in successfully'));
      } else {
        emit(AuthError('We encountered an issue signing you in. Please try again'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please check your email or sign up';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been temporarily disabled. Please contact support';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please wait a moment and try again';
          break;
        default:
          errorMessage = 'We encountered an issue signing you in. Please try again';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('Something went wrong. Please check your connection and try again'));
    }
  }
}

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}