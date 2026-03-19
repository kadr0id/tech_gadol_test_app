import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // За замовчуванням беремо системну тему
  ThemeCubit() : super(ThemeMode.system);

  void toggleTheme() {
    // Якщо поточна тема світла (або системна і зараз світло) -> робимо темну, і навпаки
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}