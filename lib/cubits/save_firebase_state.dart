part of 'save_firebase_cubit.dart';

abstract class SaveFirebaseState {
  const SaveFirebaseState();
}

class SaveFirebaseInitial extends SaveFirebaseState {}

class SaveFirebaseLoading extends SaveFirebaseState {}

class SaveFirebaseSuccess extends SaveFirebaseState {
  final int messageCount;
  
  const SaveFirebaseSuccess(this.messageCount);
}

class SaveFirebaseError extends SaveFirebaseState {
  final String message;
  
  const SaveFirebaseError(this.message);
}

class SaveFirebaseDeleted extends SaveFirebaseState {}