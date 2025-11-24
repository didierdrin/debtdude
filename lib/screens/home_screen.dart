import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debtdude/cubits/save_firebase_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stats_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'package:debtdude/widgets/dialog_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    StatsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withValues(alpha: 0.2),
          //     blurRadius: 10,
          //     offset: const Offset(0, -2),
          //   ),
          // ],
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
    return BlocProvider(
      create: (context) => SaveFirebaseCubit()..readAndSaveSmsToFirebase(),
      child: const _HomeContentBody(),
    );
  }
}

class _HomeContentBody extends StatelessWidget {
  const _HomeContentBody();

  @override
  Widget build(BuildContext context) {
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

                  // Header with greeting
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
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    FirebaseAuth.instance.currentUser?.email?.isNotEmpty == true
                                        ? FirebaseAuth.instance.currentUser!.email![0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Color(0xFF5573F6),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello 👋",
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
                          const SizedBox(width: 40),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
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
                                children: [
                                  const Text(
                                    "Your Balance",
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  StreamBuilder<int?>(
                                    stream: context.read<SaveFirebaseCubit>().getMostRecentBalance(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Text(
                                          "RWF ${snapshot.data!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}\n",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      return const Text(
                                        "RWF ---.--",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
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

                  // Recent transactions section
                  BlocBuilder<SaveFirebaseCubit, SaveFirebaseState>(
                    builder: (context, state) {
                      if (state is SaveFirebaseLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: context.read<SaveFirebaseCubit>().getRecentTransactions(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recent Transactions",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No transactions found. Make sure to grant SMS permissions.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          final transactions = snapshot.data!;

                          return Padding(
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
                                                // Ask DebtDude pressed
                                              },
                                              onMarkAsRead: () {
                                                Navigator.pop(context);
                                                // Add your Mark as Read functionality here
                                                // Mark as Read pressed
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
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tx["name"],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
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
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  (isIncome
                                                      ? "+RWF ${tx['amount']}"
                                                      : "-RWF ${tx['amount'].abs()}"),
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
                          );
                        },
                      );
                    },
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
// import 'stats_screen.dart';
// import 'chat_screen.dart';
// import 'profile_screen.dart';
// import 'conversation_screen.dart';
// import 'package:debtdude/widgets/dialog_box.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     const HomeContent(),
//     const StatsScreen(),
//     const ChatScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(8),
//             topRight: Radius.circular(8),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           selectedItemColor: const Color(0xFF5573F6),
//           unselectedItemColor: Colors.grey,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.bar_chart_outlined),
//               activeIcon: Icon(Icons.bar_chart),
//               label: 'Stats',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.chat_bubble_outline),
//               activeIcon: Icon(Icons.chat_bubble),
//               label: 'Chats',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomeContent extends StatelessWidget {
//   const HomeContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> transactions = [
//       {"name": "YouTube", "type": "Subscription Payment", "amount": -15, "date": "19 May 2024"},
//       {"name": "Stripe", "type": "Monthly Salary", "amount": 3000, "date": "15 May 2024"},
//       {"name": "Google Play", "type": "E-book Purchase", "amount": -13, "date": "10 May 2024"},
//       {"name": "OVO", "type": "Music Subscription", "amount": -8, "date": "8 May 2024"},
//     ];

//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFF5573F6),
//             Colors.white,
//           ],
//         ),
//       ),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                   child: Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: const BoxDecoration(
//                             color: Colors.transparent,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(8),
//                               topRight: Radius.circular(8),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                              Row(
//                               children: [
//                                  Padding(
//                                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
//                                    child: const CircleAvatar(
//                                                                  radius: 22,
//                                                                  backgroundColor: Colors.white,
//                                                                  child: Icon(
//                                     Icons.person,
//                                     color: Color(0xFF5573F6),
//                                                                  ),
//                                                                ),
//                                  ),
                  
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Text(
//                                     "Hello Hilal 👋",
//                                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     "Welcome back",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               ],
//                              ),
//                               const SizedBox(width: 40), // For balanced spacing
//                             ],
//                           ),
//                         ),
//                 ),

//                 // Main white card container
//                 Container(
//                   width: 350,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
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
                      
                      
                      
//                       // Balance section
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
                              
//                               children: const [
//                                 Text(
//                                   "Your Balance",
//                                   style: TextStyle(color: Colors.grey, fontSize: 14),
//                                 ),
//                                 SizedBox(height: 6),
//                                 Text(
//                                   "RWF 41,379.00",
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

                   
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),



//                    // Recent transactions
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
//                                 color: Colors.black,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Column(
//                               children: transactions.map((tx) {
//                                 bool isIncome = tx["amount"] > 0;
            
//                                 return GestureDetector(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         return DialogBox(
//                                           title: tx["name"],
//                                           content: "${tx["type"]} - ${tx["date"]}",
//                                           onAskDebtDude: () {
//                                             Navigator.pop(context);
//                                             // Add your Ask DebtDude functionality here
//                                             print('Ask DebtDude pressed for ${tx["name"]}');
//                                           },
//                                           onMarkAsRead: () {
//                                             Navigator.pop(context);
//                                             // Add your Mark as Read functionality here
//                                             print('Mark as Read pressed for ${tx["name"]}');
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Container(
//                                     margin: const EdgeInsets.only(bottom: 10),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[50],
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                         color: Colors.grey[200]!,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               tx["name"],
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             Text(
//                                               tx["type"],
//                                               style: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 13,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.end,
//                                           children: [
//                                             Text(
//                                               (isIncome
//                                                   ? "+\$${tx['amount']}"
//                                                   : "-\$${tx['amount'].abs()}"),
//                                               style: TextStyle(
//                                                 color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 15,
//                                               ),
//                                             ),
//                                             Text(
//                                               tx["date"],
//                                               style: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       ),



//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





