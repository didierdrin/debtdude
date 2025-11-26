import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService = NotificationService();

  NotificationCubit() : super(NotificationState(isEnabled: false));

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      final isEnabled = await _notificationService.isNotificationEnabled();
      emit(NotificationState(isEnabled: isEnabled));
    } catch (e) {
      emit(NotificationState(isEnabled: false));
    }
  }

  Future<void> toggleNotification() async {
    try {
      final newState = !state.isEnabled;
      await _notificationService.setNotificationEnabled(newState);
      emit(NotificationState(isEnabled: newState));
    } catch (e) {
      // Keep the current state if there's an error
    }
  }
}