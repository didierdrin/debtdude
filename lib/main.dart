import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:debtdude/screens/signup_signin_screen.dart';
import 'package:debtdude/cubits/chat_cubit.dart';
import 'package:debtdude/cubits/theme_cubit.dart';
import 'package:debtdude/cubits/currency_cubit.dart';
import 'package:debtdude/cubits/sms_analysis_cubit.dart';
import 'package:debtdude/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
