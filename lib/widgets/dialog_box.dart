import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAskDebtDude;
  final VoidCallback onMarkAsRead;
  
  const DialogBox({
    super.key,
    required this.title,
    required this.content,
    required this.onAskDebtDude,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Content
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons/Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ask DebtDude Button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: onAskDebtDude,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5573F6),
                        side: const BorderSide(
                          color: Color(0xFF5573F6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Ask DebtDude',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Mark as Read Button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: onMarkAsRead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5573F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark as Read',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use the DialogBox:
/*
showDialog(
  context: context,
  builder: (BuildContext context) {
    return DialogBox(
      title: 'Notification Title',
      content: 'This is the content of the notification that was clicked from the list tile.',
      onAskDebtDude: () {
        Navigator.pop(context); // Close dialog
        // Add your Ask DebtDude functionality here
        print('Ask DebtDude pressed');
      },
      onMarkAsRead: () {
        Navigator.pop(context); // Close dialog
        // Add your Mark as Read functionality here
        print('Mark as Read pressed');
      },
    );
  },
);
*/