import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debtdude/cubits/save_firebase_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'stats_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'package:debtdude/widgets/dialog_box.dart';
import 'package:debtdude/widgets/theme_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debtdude/cubits/currency_cubit.dart';

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
      
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF5573F6),
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); 
                                },
                                child: Padding(
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
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello,", // 👋
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
                          const ThemeToggle(),
                        ],
                      ),
                    ),
                  ),

                  // Main white card container
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
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
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      return Text(
                                        "RWF ***.**",
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Today, ${DateFormat('MMM dd, yyyy').format(DateTime.now())}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w700),
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
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recent Transactions",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                                Text(
                                  "Recent Transactions",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Theme.of(context).dividerColor,
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
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                                                  BlocBuilder<CurrencyCubit, CurrencyState>(
                                                    builder: (context, currencyState) {
                                                      return Text(
                                                        (isIncome
                                                            ? "+${context.read<CurrencyCubit>().formatAmount(tx['amount'])}"
                                                            : "-${context.read<CurrencyCubit>().formatAmount(tx['amount'].abs())}"),
                                                        style: TextStyle(
                                                          color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      );
                                                    },
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
