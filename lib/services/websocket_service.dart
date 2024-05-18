import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mangovault/constants.dart';

class WebSocketService {
  late StompClient _stompClient;
  late String authToken;

  Function(String message)? _callback;

  final _messageQueue = <String>[];

  bool _loginAttempt = true;
  bool _isReady = false;
  String username;
  String password;

  WebSocketService({
    required this.username,
    required this.password,
  }) {
    authToken = base64.encode(utf8.encode('$username:$password'));
  }

  void authenticate(Function(bool success) onAuthenticationResult) {
    _stompClient = StompClient(
      config: StompConfig(
          url: serverUrl,
          onConnect: (StompFrame frame) {
            _loginAttempt = true;
            markNotReady();

            _stompClient?.subscribe(
              destination: '/user/queue/chat',
              callback: (frame) {
                if (_isReady) {
                  _processMessage(frame.body!);
                } else {
                  _messageQueue.add(frame.body!);
                }
              },
            );

            onAuthenticationResult(true);
          },
          webSocketConnectHeaders: {'Authorization': 'Basic $authToken'},
          onWebSocketError: (dynamic error) {
            if (_loginAttempt) {
              _stompClient?.deactivate();
            }

            onAuthenticationResult(false);
            print(error.toString());
          }),
    );

    _stompClient?.activate();
  }

  void sendMessage(String message) {
    _stompClient?.send(
      destination: "/app/chat",
      body: message,
    );
  }

  void setCallback(Function(String message) callback) {
    _callback = callback;
  }

  void markReady() {
    _isReady = true;
    _messageQueue.forEach(_processMessage);
    _messageQueue.clear();
  }

  void markNotReady() {
    _isReady = false;
  }

  void disconnect() {
    _stompClient?.deactivate();
  }

  void _processMessage(String message) {
    _callback?.call(message);
  }
}
