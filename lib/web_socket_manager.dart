import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  final _messageQueue = <String>[];
  Function(String message)? _callback;

  late final WebSocketChannel _channel;
  late final StreamSubscription<dynamic> _subscription;

  bool _isReady = false;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.0.16:8080/ws'));

    _subscription.onData((message) {
      if (_isReady) {
        _processMessage(message);
      } else {
        _messageQueue.add(message);
      }
    });
  }

  void authenticate(
    String username,
    String password,
    Function(bool success) onAuthenticationResult,
  ) {
    final credentials =
        jsonEncode({'username': username, 'password': password});

    _channel.sink.add(credentials);
    _subscription = _channel.stream.listen(
      (message) {
        final response = jsonDecode(message);

        if (response['success']) {
          markNotReady();
          // connect();
        }

        onAuthenticationResult(response['success']);
      },
      cancelOnError: true,
    );
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
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
    _channel.sink.close();
  }

  void _processMessage(String message) {
    _callback?.call(message);
  }
}
