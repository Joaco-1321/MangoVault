import 'package:flutter/material.dart';

class AuthModeNotifier with ChangeNotifier {
  bool _isLogin = true;

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  bool get isLogin => _isLogin;
}
