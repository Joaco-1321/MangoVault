import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mangovault/constants.dart';

class WebSocketService {
  late StompClient _stompClient;

  final Map<String, Function(StompFrame)> _suscriptions = {};

  bool _shouldReconnect = false;
  bool _isReady = false;

  WebSocketService();

  void connect(
    String authToken, {
    Function? onConnect,
    Function(String)? onError,
  }) {
    final config = StompConfig(
        url: serverUrl,
        webSocketConnectHeaders: {'Authorization': 'Basic $authToken'},
        onConnect: (frame) => onConnect!(),
        onWebSocketError: (dynamic error) {
          if (!_shouldReconnect) {
            _stompClient.deactivate();
            onError?.call(error.toString());
          }
        });

    _stompClient = StompClient(config: config);
    _stompClient.activate();
  }

  void subscribe(String destination, Function(StompFrame) callback) {
    _stompClient.subscribe(
      destination: destination,
      callback: callback,
    );
  }

  void sendMessage(String message) {
    _stompClient.send(
      destination: "/app/chat",
      body: message,
    );
  }

  void disconnect() {
    _stompClient.deactivate();
  }
}
