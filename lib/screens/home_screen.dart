import 'package:flutter/material.dart';
import 'stats_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'conversation_screen.dart';
import 'package:debtdude/widgets/dialog_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const StatsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF5573F6),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {"name": "YouTube", "type": "Subscription Payment", "amount": -15, "date": "19 May 2024"},
      {"name": "Stripe", "type": "Monthly Salary", "amount": 3000, "date": "15 May 2024"},
      {"name": "Google Play", "type": "E-book Purchase", "amount": -13, "date": "10 May 2024"},
      {"name": "OVO", "type": "Music Subscription", "amount": -8, "date": "8 May 2024"},
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5573F6),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                             Row(
                              children: [
                                 Padding(
                                   padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                                   child: const CircleAvatar(
                                                                 radius: 22,
                                                                 backgroundColor: Colors.white,
                                                                 child: Icon(
                                    Icons.person,
                                    color: Color(0xFF5573F6),
                                                                 ),
                                                               ),
                                 ),
                  
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Hello Hilal 👋",
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Welcome back",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ],
                             ),
                              const SizedBox(width: 40), // For balanced spacing
                            ],
                          ),
                        ),
                ),

                // Main white card container
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      
                      
                      
                      // Balance section
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              
                              children: const [
                                Text(
                                  "Your Balance",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "RWF 41,379.00",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                   
                    ],
                  ),
                ),
                const SizedBox(height: 20),



                   // Recent transactions
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recent Transactions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: transactions.map((tx) {
                                bool isIncome = tx["amount"] > 0;
            
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DialogBox(
                                          title: tx["name"],
                                          content: "${tx["type"]} - ${tx["date"]}",
                                          onAskDebtDude: () {
                                            Navigator.pop(context);
                                            // Add your Ask DebtDude functionality here
                                            print('Ask DebtDude pressed for ${tx["name"]}');
                                          },
                                          onMarkAsRead: () {
                                            Navigator.pop(context);
                                            // Add your Mark as Read functionality here
                                            print('Mark as Read pressed for ${tx["name"]}');
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              tx["type"],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              (isIncome
                                                  ? "+\$${tx['amount']}"
                                                  : "-\$${tx['amount'].abs()}"),
                                              style: TextStyle(
                                                color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              tx["date"],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';


// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> transactions = [
//       {"name": "YouTube", "type": "Subscription Payment", "amount": -15, "date": "19 May 2024"},
//       {"name": "Stripe", "type": "Monthly Salary", "amount": 3000, "date": "15 May 2024"},
//       {"name": "Google Play", "type": "E-book Purchase", "amount": -13, "date": "10 May 2024"},
//       {"name": "OVO", "type": "Music Subscription", "amount": -8, "date": "8 May 2024"},
//     ];

//     return Scaffold(
//       backgroundColor: , // Linear gradient from top to bottom
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 // Main white card container
//                 Container(
//                   width: 350,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Purple balance section
//                       Container(
//                         decoration: const BoxDecoration(
//                           color: Colors.white, 
//                           borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(30),
//                             bottomRight: Radius.circular(30),
//                           ),
//                         ),
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: const [
//                                     Text(
//                                       "Hello Hilal 👋",
//                                       style: TextStyle(color: Colors.white70, fontSize: 14),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       "Welcome back",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 CircleAvatar(
//                                   radius: 22,
//                                   backgroundImage: AssetImage('assets/profile.jpg'),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               "Your Balance",
//                               style: TextStyle(color: Colors.white70, fontSize: 14),
//                             ),
//                             const SizedBox(height: 6),
//                             const Text(
//                               "\$41,379.00",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             // Row(
//                             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             //   children: const [
//                             //     _ActionButton(label: "Transfer"),
//                             //     _ActionButton(label: "Withdraw"),
//                             //     _ActionButton(label: "Invest"),
//                             //     _ActionButton(label: "Top Up"),
//                             //   ],
//                             // ),
//                           ],
//                         ),
//                       ),

//                       // Recent transactions
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "Recent Transactions",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Column(
//                               children: transactions.map((tx) {
//                                 bool isIncome = tx["amount"] > 0;
//                                 return Container(
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[50],
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             tx["name"],
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                           Text(
//                                             tx["type"],
//                                             style: const TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 13,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             (isIncome
//                                                 ? "+\$${tx["amount"]}"
//                                                 : "-\$${tx["amount"].abs()}"),
//                                             style: TextStyle(
//                                               color: isIncome ? Colors.green : Colors.red,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15,
//                                             ),
//                                           ),
//                                           Text(
//                                             tx["date"],
//                                             style: const TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final String label;

//   const _ActionButton({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFF3B1E8E),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
