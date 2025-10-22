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
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess('Sign up successful'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess('Sign in successful'));
    } catch (e) {
      emit(AuthError(e.toString()));
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