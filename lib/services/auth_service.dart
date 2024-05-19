import 'package:flutter/material.dart';
import 'package:mangovault/services/websocket_service.dart';

class AuthService with ChangeNotifier {
  final WebSocketService _webSocketService;

  bool _isAuthenticated = false;
  String _message = '';

  bool get isAuthenticated => _isAuthenticated;

  String get message => _message;

  AuthService(this._webSocketService);

  void authenticate(String username, String password) {
    _webSocketService.connect(
      username,
      password,
      onConnect: _onConnect,
      onError: _onError,
    );

    notifyListeners();
  }

  void _onConnect() {
    _isAuthenticated = true;
    _message = 'authentication successful';
    notifyListeners();
  }

  void _onError(String error) {
    _isAuthenticated = false;
    _message = 'authentication failed failed';
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _message = '';
    _webSocketService.disconnect();
    notifyListeners();
  }
}
