import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String campaignId = '8361915152303308135';

  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await _initializeLocalNotifications();
      
      // Request permission
      await _requestPermission();
      
      // Get FCM token
      await _getFCMToken();
      
      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      // Error initializing notifications
    }
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Notification tapped
        },
      );
      
      // Create notification channel for Android
      await _createNotificationChannel();
    } catch (e) {
      // Error initializing local notifications
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'debtdude_channel',
      'DebtDude Notifications',
      description: 'Notifications for DebtDude app',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String?> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      // Error getting FCM token
      return null;
    }
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Message clicked
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'debtdude_channel',
      'DebtDude Notifications',
      channelDescription: 'Notifications for DebtDude app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'DebtDude',
      message.notification?.body ?? 'New notification',
      platformChannelSpecifics,
    );
  }

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);
      
      // Add a small delay to ensure initialization is complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (enabled) {
        await _sendStartingNotification();
      } else {
        await _sendStoppingNotification();
      }
    } catch (e) {
      // Error setting notification enabled
    }
  }

  Future<void> _sendStartingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'debtdude_channel',
      'DebtDude Notifications',
      channelDescription: 'Notifications for DebtDude app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      campaignId.hashCode,
      'Notifications Enabled',
      'DebtDude notifications are now active. Campaign ID: $campaignId',
      platformChannelSpecifics,
    );
  }

  Future<void> _sendStoppingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'debtdude_channel',
      'DebtDude Notifications',
      channelDescription: 'Notifications for DebtDude app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      '${campaignId}_stop'.hashCode,
      'Notifications Disabled',
      'DebtDude notifications have been turned off.',
      platformChannelSpecifics,
    );
  }

  Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'debtdude_channel',
      'DebtDude Notifications',
      channelDescription: 'Notifications for DebtDude app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      999,
      'Test Notification',
      'This is a test notification from DebtDude!',
      platformChannelSpecifics,
    );
  }
}