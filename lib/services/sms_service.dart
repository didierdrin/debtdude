import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sms_reader');

  // Check SMS permission
  Future<bool> checkSmsPermission() async {
    final status = await Permission.sms.status;
    if (!status.isGranted) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    return true;
  }

  // Get all SMS messages
  Future<List<SmsMessage>> getInboxSms() async {
    try {
      final hasPermission = await checkSmsPermission();
      if (!hasPermission) {
        throw Exception('SMS permission denied');
      }

      final List<dynamic> result = await _channel.invokeMethod('getInboxSms');
      return result.map((item) => SmsMessage.fromMap(item)).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get SMS: ${e.message}');
    }
  }

  // Listen for new SMS messages
  void listenForNewSms(Function(SmsMessage) onNewSms) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onNewSms') {
        final message = SmsMessage.fromMap(call.arguments);
        onNewSms(message);
      }
    });
  }
}

class SmsMessage {
  final String? address;
  final String? body;
  final int? date;

  SmsMessage({
    this.address,
    this.body,
    this.date,
  });

  factory SmsMessage.fromMap(Map<dynamic, dynamic> map) {
    return SmsMessage(
      address: map['address'],
      body: map['body'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'body': body,
      'date': date,
    };
  }
}