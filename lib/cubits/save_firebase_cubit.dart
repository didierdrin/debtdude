import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:debtdude/services/sms_service.dart';

part 'save_firebase_state.dart';

class SaveFirebaseCubit extends Cubit<SaveFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SmsService _smsService = SmsService(); 

  SaveFirebaseCubit() : super(SaveFirebaseInitial());

  // Check SMS permission
   Future<bool> checkSmsPermission() async {
    return await _smsService.checkSmsPermission();
  }

  // Parse SMS message and extract transaction data
  Map<String, dynamic>? _parseTransaction(String body, String address, int date) {
    try {
      // Check if SMS is from relevant services
      final lowerBody = body.toLowerCase();
      final isMMoney = lowerBody.contains('m-money') || address.contains('MMoney');
      final isMokash = lowerBody.contains('mokash') || address.contains('Mokash');
      final isAirtelMoney = lowerBody.contains('airtelmoney') || address.contains('AirtelMoney') || lowerBody.contains('*151*') || lowerBody.contains('*165*');

      if (!isMMoney && !isMokash && !isAirtelMoney) {
        return null;
      }

      Map<String, dynamic>? transaction;
      
      // M-Money parsing
      if (isMMoney) {
        transaction = _parseMMoney(body, date);
      }
      // Mokash parsing
      else if (isMokash) {
        transaction = _parseMokash(body, date);
      }
      // AirtelMoney parsing
      else if (isAirtelMoney) {
        transaction = _parseAirtelMoney(body, date);
      }

      return transaction;
    } catch (e) {
      print('Error parsing transaction: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseMMoney(String body, int date) {
    try {
      // Money received pattern
      final receivedRegex = RegExp(r'received (\d+(?:,\d+)*) RWF from (.+?) \(.*\) at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
      final receivedMatch = receivedRegex.firstMatch(body);
      
      if (receivedMatch != null) {
        final amount = _parseAmount(receivedMatch.group(1)!);
        final from = receivedMatch.group(2)!.trim();
        final transactionDate = receivedMatch.group(3)!;
        
        return {
          'name': from,
          'type': 'Money Received',
          'amount': amount,
          'date': _formatDate(transactionDate),
          'timestamp': date,
          'service': 'M-Money',
          'category': 'received',
          'original_body': body,
        };
      }

      // Money sent pattern
      final sentRegex = RegExp(r'(\d+(?:,\d+)*) RWF transferred to (.+?) \(\d+\) at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
      final sentMatch = sentRegex.firstMatch(body);
      
      if (sentMatch != null) {
        final amount = _parseAmount(sentMatch.group(1)!);
        final to = sentMatch.group(2)!.trim();
        final transactionDate = sentMatch.group(3)!;
        
        return {
          'name': to,
          'type': 'Money Sent',
          'amount': -amount, // Negative for sent money
          'date': _formatDate(transactionDate),
          'timestamp': date,
          'service': 'M-Money',
          'category': 'sent',
          'original_body': body,
        };
      }

      // Vendor payment pattern
      final vendorRegex = RegExp(r'payment of (\d+(?:,\d+)*) RWF to (.+?) was completed at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
      final vendorMatch = vendorRegex.firstMatch(body);
      
      if (vendorMatch != null) {
        final amount = _parseAmount(vendorMatch.group(1)!);
        final vendor = vendorMatch.group(2)!.trim();
        final transactionDate = vendorMatch.group(3)!;
        
        return {
          'name': vendor,
          'type': 'Vendor Payment',
          'amount': -amount,
          'date': _formatDate(transactionDate),
          'timestamp': date,
          'service': 'M-Money',
          'category': 'vendor-paid',
          'original_body': body,
        };
      }

      return null;
    } catch (e) {
      print('Error parsing M-Money: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseMokash(String body, int date) {
    try {
      // Loan paid pattern
      final loanPaidRegex = RegExp(r'twavanye FRW (\d+(?:,\d+)*) kuri konti');
      final loanPaidMatch = loanPaidRegex.firstMatch(body);
      
      if (loanPaidMatch != null) {
        final amount = _parseAmount(loanPaidMatch.group(1)!);
        
        return {
          'name': 'Mokash Loan',
          'type': 'Loan Repayment',
          'amount': -amount,
          'date': _formatTimestamp(date),
          'timestamp': date,
          'service': 'Mokash',
          'category': 'loan-paid',
          'original_body': body,
        };
      }

      // Loan received pattern
      final loanReceivedRegex = RegExp(r'Inguzanyo yawe ya (\d+(?:,\d+)*)');
      final loanReceivedMatch = loanReceivedRegex.firstMatch(body);
      
      if (loanReceivedMatch != null) {
        final amount = _parseAmount(loanReceivedMatch.group(1)!);
        
        return {
          'name': 'Mokash Loan',
          'type': 'Loan Received',
          'amount': amount,
          'date': _formatTimestamp(date),
          'timestamp': date,
          'service': 'Mokash',
          'category': 'loan-received',
          'original_body': body,
        };
      }

      return null;
    } catch (e) {
      print('Error parsing Mokash: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseAirtelMoney(String body, int date) {
    try {
      // Money received pattern
      final receivedRegex = RegExp(r'received RWF (\d+(?:,\d+)*) from (.+?) in');
      final receivedMatch = receivedRegex.firstMatch(body);
      
      if (receivedMatch != null) {
        final amount = _parseAmount(receivedMatch.group(1)!);
        final from = receivedMatch.group(2)!.trim();
        
        return {
          'name': from,
          'type': 'Money Received',
          'amount': amount,
          'date': _formatTimestamp(date),
          'timestamp': date,
          'service': 'AirtelMoney',
          'category': 'received',
          'original_body': body,
        };
      }

      // Money sent pattern
      final sentRegex = RegExp(r'sent to (.+?) in MTN . Amt RWF (\d+(?:,\d+)*)');
      final sentMatch = sentRegex.firstMatch(body);
      
      if (sentMatch != null) {
        final amount = _parseAmount(sentMatch.group(2)!);
        final to = sentMatch.group(1)!.trim();
        
        return {
          'name': to,
          'type': 'Money Sent',
          'amount': -amount,
          'date': _formatTimestamp(date),
          'timestamp': date,
          'service': 'AirtelMoney',
          'category': 'sent',
          'original_body': body,
        };
      }

      // Vendor payment pattern (same as M-Money)
      final vendorRegex = RegExp(r'payment of (\d+(?:,\d+)*) RWF to (.+?) was completed at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
      final vendorMatch = vendorRegex.firstMatch(body);
      
      if (vendorMatch != null) {
        final amount = _parseAmount(vendorMatch.group(1)!);
        final vendor = vendorMatch.group(2)!.trim();
        final transactionDate = vendorMatch.group(3)!;
        
        return {
          'name': vendor,
          'type': 'Vendor Payment',
          'amount': -amount,
          'date': _formatDate(transactionDate),
          'timestamp': date,
          'service': 'AirtelMoney',
          'category': 'vendor-paid',
          'original_body': body,
        };
      }

      return null;
    } catch (e) {
      print('Error parsing AirtelMoney: $e');
      return null;
    }
  }

  int _parseAmount(String amountStr) {
    try {
      return int.parse(amountStr.replaceAll(',', ''));
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String dateStr) {
    try {
      // Convert "2025-10-25 17:31:27" to "25 Oct 2025"
      final parts = dateStr.split(' ');
      final dateParts = parts[0].split('-');
      final year = dateParts[0];
      final month = int.parse(dateParts[1]);
      final day = dateParts[2];
      
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      return '$day ${months[month - 1]} $year';
    } catch (e) {
      return _formatTimestamp(DateTime.now().millisecondsSinceEpoch);
    }
  }

  String _formatTimestamp(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown Date';
    }
  }


Future<void> readAndSaveSmsToFirebase() async {
    try {
      emit(SaveFirebaseLoading());
      
      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in');
        emit(SaveFirebaseError('User not logged in'));
        return;
      }

      print('Checking SMS permission...');
      final hasPermission = await checkSmsPermission();
      if (!hasPermission) {
        print('SMS permission denied');
        emit(SaveFirebaseError('SMS permission denied. Please grant SMS permission.'));
        return;
      }

      print('Querying SMS messages...');
      final messages = await _smsService.getInboxSms();
      print('Retrieved ${messages.length} SMS messages');

      // Parse transactions from messages
      final List<Map<String, dynamic>> transactions = [];
      
      for (final message in messages) {
        print('Processing SMS: ${message.address} - ${message.body}');
        final transaction = _parseTransaction(
          message.body ?? '', 
          message.address ?? '', 
          message.date ?? 0
        );
        if (transaction != null) {
          print('Parsed transaction: $transaction');
          transactions.add(transaction);
        }
      }

      print('Total transactions parsed: ${transactions.length}');

      // Sort transactions by timestamp (newest first)
      transactions.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

      // Save to Firebase
      print('Saving to Firebase...');
      await _firestore
          .collection('user_transactions')
          .doc(user.uid)
          .set({
            'transactions': transactions,
            'last_updated': FieldValue.serverTimestamp(),
            'total_transactions': transactions.length,
          }, SetOptions(merge: true));

      print('Successfully saved ${transactions.length} transactions to Firebase');
      emit(SaveFirebaseSuccess(transactions.length));
      
    } catch (e) {
      print('Error in readAndSaveSmsToFirebase: $e');
      emit(SaveFirebaseError('Failed to read and save SMS: $e'));
    }
  }



// void listenForNewSms() {
//   SmsReceiver receiver = SmsReceiver();
//   receiver.onSmsReceived.listen((SmsMessage msg) {
//     // Parse and save single new msg
//   });
// }

  // Get stored transactions from Firebase
  Stream<DocumentSnapshot> getStoredTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('user_transactions')
        .doc(user.uid)
        .snapshots();
  }


  // Get recent transactions (last 10)
  Stream<List<Map<String, dynamic>>> getRecentTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('user_transactions')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return [];
          final data = snapshot.data() as Map<String, dynamic>;
          final transactions = data['transactions'] as List<dynamic>? ?? [];
          
          // Convert to List<Map<String, dynamic>> and take last 10
          return transactions
              .cast<Map<String, dynamic>>()
              .take(10)
              .toList();
        });
  }

  // Delete all transaction data for current user
  Future<void> deleteTransactionData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_transactions')
          .doc(user.uid)
          .delete();

      emit(SaveFirebaseDeleted());
    } catch (e) {
      emit(SaveFirebaseError('Failed to delete transaction data: $e'));
    }
  }
}