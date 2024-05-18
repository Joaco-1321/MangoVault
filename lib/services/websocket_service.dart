import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mangovault/constants.dart';

class WebSocketService {
  late StompClient _stompClient;
  late String authToken;

  Function(String message)? _callback;
  Function? onConnectCallback;
  Function(String)? onErrorCallback;

  final _messageQueue = <String>[];

  bool _shouldReconnect = false;
  bool _isReady = false;
  String username;
  String password;

  WebSocketService({
    required this.username,
    required this.password,
    this.onConnectCallback,
    this.onErrorCallback,
  }) {
    authToken = base64.encode(utf8.encode('$username:$password'));
  }

  void authenticate() {
    _stompClient = StompClient(
      config: StompConfig(
          url: serverUrl,
          onConnect: (StompFrame frame) {
            _shouldReconnect = true;

            onConnectCallback?.call();

            markNotReady();

            _stompClient.subscribe(
              destination: '/user/queue/chat',
              callback: (frame) {
                if (_isReady) {
                  _processMessage(frame.body!);
                } else {
                  _messageQueue.add(frame.body!);
                }
              },
            );
          },
          webSocketConnectHeaders: {'Authorization': 'Basic $authToken'},
          onWebSocketError: (dynamic error) {
            if (!_shouldReconnect) {
              _stompClient.deactivate();
              onErrorCallback?.call(error.toString());
            }
          }),
    );

    _stompClient.activate();
  }

  void sendMessage(String message) {
    _stompClient.send(
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
    _stompClient.deactivate();
  }

  void _processMessage(String message) {
    _callback?.call(message);
  }
}
