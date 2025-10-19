import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void signUp(String username, String password, String confirmPassword) {
    if (password == confirmPassword) {
      emit(AuthLoading());
      // Simulate sign-up process
      Future.delayed(Duration(seconds: 1), () {
        emit(AuthSuccess('Sign up successful'));
      });
    } else {
      emit(AuthError('Passwords do not match'));
    }
  }

  void signIn(String username, String password) {
    emit(AuthLoading());
    // Simulate sign-in process
    Future.delayed(Duration(seconds: 1), () {
      emit(AuthSuccess('Sign in successful'));
    });
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