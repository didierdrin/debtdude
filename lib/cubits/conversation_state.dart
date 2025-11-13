part of 'conversation_cubit.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class MessageSending extends ConversationState {}

class MessagesLoaded extends ConversationState {
  final List<dynamic> messages;
  MessagesLoaded(this.messages);
}

class MessageSent extends ConversationState {
  final Map<String, dynamic> messageData;
  MessageSent(this.messageData);
}

class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
}