import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  Color get primaryColor => _isDarkTheme ? const Color(0xFF1A0A3E) : const Color(0xFF4A90E2);
  Color get secondaryColor => _isDarkTheme ? const Color(0xFF4A2B8F) : const Color(0xFF5BA3F5);
  Color get backgroundColor => _isDarkTheme ? const Color(0xFF0D0621) : const Color(0xFFF5F5F5);
  Color get cardColor => _isDarkTheme ? const Color(0xFF2D1B5E) : Colors.white;
  Color get textColor => _isDarkTheme ? Colors.white : Colors.black;
}