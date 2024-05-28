import 'package:flutter/material.dart';
import 'package:mangovault/services/websocket_service.dart';

class NotificationService with ChangeNotifier {
  final WebSocketService _webSocketService;

  NotificationService(this._webSocketService);
}
