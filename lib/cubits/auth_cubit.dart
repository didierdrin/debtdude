import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthCubit() : super(AuthInitial());

  Future<void> signUp(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      emit(AuthError('Passwords do not match'));
      return;
    }
    
    emit(AuthLoading());
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      if (result.user != null) {
        emit(AuthSuccess('Sign up successful'));
      } else {
        emit(AuthError('Sign up failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      if (result.user != null) {
        emit(AuthSuccess('Sign in successful'));
      } else {
        emit(AuthError('Sign in failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign in failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
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