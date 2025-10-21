import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Tabs for Withdraw, Received, Tracking
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _topButton("WITHDRAW", true),
                _topButton("RECEIVED", false),
                _topButton("TRACKING", false),
              ],
            ),
          ),

          // List of notifications
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _notificationTile();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Top tab button style
  Widget _topButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigoAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigoAccent),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.indigoAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Notification card
  Widget _notificationTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.blue),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "John - Debt Record",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "You borrowed 15,000 on",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const Text("2:15 pm", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
