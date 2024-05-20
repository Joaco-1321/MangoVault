import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangovault/constants.dart';
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
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      authenticate(username, password);
    } else {
      _message = json.decode(response.body)['error'];
      notifyListeners();
    }
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
