import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(ThemeMode.light)) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state.themeMode == ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDark);
    emit(ThemeState(!isDark ? ThemeMode.dark : ThemeMode.light));
  }
}