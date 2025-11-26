import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:debtdude/screens/signup_signin_screen.dart';
import 'package:debtdude/cubits/chat_cubit.dart';
import 'package:debtdude/cubits/theme_cubit.dart';
import 'package:debtdude/cubits/currency_cubit.dart';
import 'package:debtdude/cubits/sms_analysis_cubit.dart';
import 'package:debtdude/cubits/save_firebase_cubit.dart';
import 'package:debtdude/cubits/notification_cubit.dart';
import 'package:debtdude/theme/app_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  


  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Firebase initialization failed
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => CurrencyCubit()),
        BlocProvider(create: (context) => SmsAnalysisCubit()),
        BlocProvider(create: (context) => SaveFirebaseCubit()),
        BlocProvider(create: (context) {
          final cubit = NotificationCubit();
          // Initialize after a short delay to ensure everything is ready
          Future.delayed(const Duration(milliseconds: 100), () {
            cubit.initialize();
          });
          return cubit;
        }),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'DebtDude',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const AuthScreen(),
          );
        },
      ),
    );
  }
}
