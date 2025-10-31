import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsService {
  // Check SMS permission with better error handling
 Future<bool> checkSmsPermission() async {
    try {
      var status = await Permission.sms.status;
      print('SMS Permission status: $status');
     
      if (!status.isGranted) {
        status = await Permission.sms.request();
        print('SMS Permission request result: $status');
        
        // If permanently denied, guide user to app settings
        if (status.isPermanentlyDenied) {
          // You can show a dialog here to guide user to app settings
          print('SMS permission permanently denied. Please enable in app settings.');
          return false;
        }
      }
      return status.isGranted;
    } catch (e) {
      print('Error checking SMS permission: $e');
      return false;
    }
  }

  // Get recent 100 inbox SMS messages (sorted DESC by date)
  Future<List<CustomSmsMessage>> getInboxSms() async {
    try {
      print('Checking SMS permission...');
      final hasPermission = await checkSmsPermission();
     
      if (!hasPermission) {
        throw Exception('SMS permission denied. Please grant SMS permission in app settings.');
      }

      print('Querying inbox SMS...');
      final SmsQuery query = SmsQuery();
      
      // Query INBOX only - use package's SmsMessage with explicit type
      List<SmsMessage> platformMessages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      // Sort by date DESC (newest first) and take recent 100
      platformMessages.sort((a, b) {
        final dateA = a.date ?? DateTime(0);
        final dateB = b.date ?? DateTime(0);
        return dateB.compareTo(dateA); // Compare DateTime objects directly
      });
      
      final recentMessages = platformMessages.take(100).toList();

      print('Retrieved ${recentMessages.length} recent inbox SMS');

      // Map to your CustomSmsMessage model
      return recentMessages.map((pmsg) => CustomSmsMessage(
        address: pmsg.address, // Use address, not sender
        body: pmsg.body,
        date: pmsg.date?.millisecondsSinceEpoch, // Convert DateTime to int
      )).toList();

    } on PlatformException catch (e) {
      print('PlatformException while getting SMS: ${e.message}');
      throw Exception('Failed to get SMS: ${e.message}');
    } catch (e) {
      print('Error getting SMS: $e');
      throw Exception('Failed to get SMS: $e');
    }
  }
}

// Renamed to avoid conflict with package's SmsMessage
class CustomSmsMessage {
  final String? address;
  final String? body;
  final int? date; // This stores milliseconds since epoch

  CustomSmsMessage({
    this.address,
    this.body,
    this.date,
  });

  factory CustomSmsMessage.fromMap(Map<dynamic, dynamic> map) {
    return CustomSmsMessage(
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

  // Helper method to convert timestamp back to DateTime if needed
  DateTime? get dateTime {
    return date != null ? DateTime.fromMillisecondsSinceEpoch(date!) : null;
  }

  @override
  String toString() {
    final bodyPreview = body != null 
        ? (body!.length > 50 ? '${body!.substring(0, 50)}...' : body!)
        : 'null';
    return 'CustomSmsMessage{address: $address, body: $bodyPreview, date: $date}';
  }
}