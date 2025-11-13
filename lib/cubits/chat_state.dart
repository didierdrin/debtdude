part of 'chat_cubit.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<dynamic> conversations;
  ConversationsLoaded(this.conversations);
}

class DashboardDataLoaded extends ChatState {
  final Map<String, dynamic> dashboardData;
  DashboardDataLoaded(this.dashboardData);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}