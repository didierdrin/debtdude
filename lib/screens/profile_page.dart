import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _smsAnalysisEnabled = true;
  String _selectedCurrency = 'RWF';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2E7D32),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+250 788 123 456',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Edit profile functionality
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  
                  // Notifications Toggle
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
                    title: const Text('Notifications'),
                    subtitle: const Text('Debt reminders and alerts'),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),

                  const Divider(height: 1),

                  // SMS Analysis Toggle
                  ListTile(
                    leading: const Icon(Icons.sms, color: Color(0xFF2E7D32)),
                    title: const Text('SMS Analysis'),
                    subtitle: const Text('Auto-categorize transactions'),
                    trailing: Switch(
                      value: _smsAnalysisEnabled,
                      onChanged: (value) {
                        setState(() {
                          _smsAnalysisEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),

                  const Divider(height: 1),

                  // Currency Selection
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
                    title: const Text('Currency'),
                    subtitle: Text('Current: $_selectedCurrency'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showCurrencyDialog();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security, color: Color(0xFF2E7D32)),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFF2E7D32)),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFF2E7D32)),
                    title: const Text('About DebtDude'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Rwandan Franc (RWF)'),
                value: 'RWF',
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('US Dollar (USD)'),
                value: 'USD',
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About DebtDude'),
          content: const Text(
            'DebtDude v1.0.0\n\n'
            'AI-powered personal finance management for Rwanda. '
            'Track debts, analyze spending, and manage your mobile money transactions with ease.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement logout functionality
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}