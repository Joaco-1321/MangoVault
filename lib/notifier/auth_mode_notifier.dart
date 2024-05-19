import 'package:flutter/material.dart';

class AuthModeNotifier with ChangeNotifier {
  bool _isLogin = true;

  bool get isLogin => _isLogin;

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }
}
