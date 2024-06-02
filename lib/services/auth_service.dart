import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangovault/constants.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/services/websocket_service.dart';

class AuthService with ChangeNotifier {
  final WebSocketService _webSocketService;

  User? _user;

  bool _isAuthenticated = false;
  String _message = '';

  User? get user => _user;

  String? get authToken => _user?.authToken;

  String? get username => _user?.username;

  bool get isAuthenticated => _isAuthenticated;

  String get message => _message;

  AuthService(this._webSocketService);

  void authenticate(String username, String password) {
    _user = User(username, base64.encode(utf8.encode('$username:$password')));

    _webSocketService.connect(
      _user!.authToken,
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
      _message = json.decode(response.body)['errors'];
      notifyListeners();
    }
  }

  void _onConnect() {
    _setState(
      isAuthenticated: true,
      message: 'authentication successful',
      notify: true,
    );
  }

  void _onError(String error) {
    _setState(
      isAuthenticated: false,
      message: 'authentication failed',
      notify: true,
    );
  }

  void logout() {
    _setState(
      isAuthenticated: false,
      message: '',
      notify: false,
    );

    _user = null;
    _webSocketService.disconnect();
    notifyListeners();
  }

  void _setState({
    required bool isAuthenticated,
    required String message,
    required bool notify,
  }) {
    _isAuthenticated = isAuthenticated;
    _message = message;

    if (notify) notifyListeners();
  }
}
