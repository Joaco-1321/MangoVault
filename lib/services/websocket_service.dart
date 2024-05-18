import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mangovault/constants.dart';

class WebSocketService {
  StompClient? client;
  Function(String message)? _callback;

  final _messageQueue = <String>[];

  bool _loginAttempt = true;
  bool _isReady = false;
  String? token;

  WebSocketService();

  void authenticate(
    String username,
    String password,
    Function(bool success) onAuthenticationResult,
  ) {
    token = base64.encode(utf8.encode("$username:$password"));

    client = StompClient(
      config: StompConfig(
          url: serverUrl,
          onConnect: (StompFrame frame) {
            _loginAttempt = true;
            markNotReady();

            client?.subscribe(
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
          webSocketConnectHeaders: {'Authorization': 'Basic $token'},
          onWebSocketError: (dynamic error) {
            if (_loginAttempt) {
              client?.deactivate();
            }

            onAuthenticationResult(false);
            print(error.toString());
          }),
    );

    client?.activate();
  }

  void sendMessage(String message) {
    client?.send(
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
    client?.deactivate();
  }

  void _processMessage(String message) {
    _callback?.call(message);
  }
}
