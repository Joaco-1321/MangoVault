import 'package:flutter/material.dart';

class AuthNotifier with ChangeNotifier {
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  bool get isLogin => _isLogin;

  bool get isPasswordVisible => _isPasswordVisible;

  bool get isRepeatPasswordVisible => _isRepeatPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleRepeatPasswordVisibility() {
    _isRepeatPasswordVisible = !_isRepeatPasswordVisible;
    notifyListeners();
  }
}
