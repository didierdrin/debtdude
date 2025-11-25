import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(ThemeMode.system));

  void toggleTheme() {
    if (state.themeMode == ThemeMode.light) {
      emit(ThemeState(ThemeMode.dark));
    } else {
      emit(ThemeState(ThemeMode.light));
    }
  }

  void setTheme(ThemeMode themeMode) {
    emit(ThemeState(themeMode));
  }
}