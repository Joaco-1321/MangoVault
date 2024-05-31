import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mangovault/constants.dart';
import 'package:mangovault/model/friend_request.dart';
import 'package:mangovault/services/api_service.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/websocket_service.dart';

class FriendService with ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthService _authService;

  List<String> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];

  List<String> get friends => _friends;

  List<FriendRequest> get receivedRequests => _receivedRequests;

  List<FriendRequest> get sentRequests => _sentRequests;

  FriendService(this._webSocketService, this._authService) {
    init();
  }

  Future<void> init() async {
    _friends = await ApiService.getJsonList(
      friendEndpoint,
      _authService.authToken!,
    );

    final tmpFriendRequests =
        (await ApiService.getJsonList<Map<String, dynamic>>(
      '$friendEndpoint/request',
      _authService.authToken!,
    ))
            .map((request) => FriendRequest.fromJson(request))
            .toList();

    for (var element in tmpFriendRequests) {
      if (element.recipient == _authService.username) {
        receivedRequests.add(element);
      } else {
        sentRequests.add(element);
      }
    }

    _webSocketService.subscribe(
      "/user/queue/notification",
      (frame) {
        final requestReceived = FriendRequest.fromJson(jsonDecode(frame.body!));

        switch (requestReceived.status) {
          case RequestStatus.pending:
            _receivedRequests.add(requestReceived);
          case RequestStatus.accepted:
            _friends.add(requestReceived.recipient);
            _sentRequests.removeWhere(
                  (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.rejected:
            _sentRequests.removeWhere(
                  (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.canceled:
            _receivedRequests.removeWhere(
              (request) => request.requester == requestReceived.requester,
            );
        }

        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<void> sendFriendRequest(String requester, String recipient) async {
    final response = await http.post(
      Uri.parse('$friendEndpoint/request/send'),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requester': requester,
        'recipient': recipient,
      }),
    );

    if (response.statusCode == 200) {
      _sentRequests.add(FriendRequest(
        requester: requester,
        recipient: recipient,
        status: RequestStatus.pending,
      ));
    }

    notifyListeners();
  }

  Future<void> acceptFriendRequest(String requester, String recipient) async {
    final response = await http.post(
      Uri.parse('$friendEndpoint/request/accept'),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requester': requester,
        'recipient': recipient,
        'status': RequestStatus.accepted.name.toUpperCase(),
      }),
    );

    if (response.statusCode == 200) {
      _friends.add(requester);
      _receivedRequests
          .removeWhere((request) => request.requester == requester);
    }

    notifyListeners();
  }

  Future<void> rejectFriendRequest(String requester, String recipient) async {
    final response = await http.post(
      Uri.parse('$friendEndpoint/request/reject'),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requester': requester,
        'recipient': recipient,
        'status': RequestStatus.rejected.name.toUpperCase(),
      }),
    );

    if (response.statusCode == 200) {
      _receivedRequests
          .removeWhere((request) => request.requester == requester);
    }

    notifyListeners();
  }

  Future<void> cancelSentRequest(String requester, String recipient) async {
    final response = await http.post(
      Uri.parse('$friendEndpoint/request/cancel'),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requester': requester,
        'recipient': recipient,
        'status': RequestStatus.canceled.name.toUpperCase(),
      }),
    );

    if (response.statusCode == 200) {
      _sentRequests.removeWhere((request) => request.recipient == recipient);
    }

    notifyListeners();
  }
}
