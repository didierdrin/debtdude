part of 'conversation_cubit.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class MessageSending extends ConversationState {}

class MessagesLoaded extends ConversationState {
  final List<Map<String, dynamic>> messages;
  MessagesLoaded(this.messages);
}

class MessageSent extends ConversationState {}

class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
}