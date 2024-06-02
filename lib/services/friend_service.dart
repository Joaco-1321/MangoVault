import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mangovault/constants.dart';
import 'package:mangovault/model/friend_request.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/services/api_service.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/websocket_service.dart';

class FriendService with ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthService _authService;

  late final User _user;

  FriendService(this._webSocketService, this._authService) {
    _user = _authService.user!;
    init();
  }

  List<String> get friends => _user.friends;

  List<FriendRequest> get sentRequests => _user.sentRequests;

  List<FriendRequest> get receivedRequests => _user.receivedRequests;

  Future<void> init() async {
    _user.friends.addAll(await ApiService.getJsonList(
      friendEndpoint,
      _authService.authToken!,
    ));

    _user.addFriendRequests((await ApiService.getJsonList<Map<String, dynamic>>(
      '$friendEndpoint/request',
      _authService.authToken!,
    ))
        .map((request) => FriendRequest.fromMap(request))
        .where((request) => request.status == RequestStatus.pending)
        .toList());

    _webSocketService.subscribe(
      "/user/queue/notification",
      (frame) {
        final requestReceived = FriendRequest.fromMap(jsonDecode(frame.body!));

        switch (requestReceived.status) {
          case RequestStatus.pending:
            _user.addFriendRequest(requestReceived);
          case RequestStatus.accepted:
            _user.friends.add(requestReceived.recipient);
            _user.sentRequests.removeWhere(
              (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.rejected:
            _user.sentRequests.removeWhere(
              (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.canceled:
            _user.receivedRequests.removeWhere(
              (request) => request.requester == requestReceived.requester,
            );
        }

        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<void> sendFriendRequest({required String recipient}) async {
    if (!_user.friends.contains(recipient)) {
      final statusCode = await _operateFriendRequest(
        username: recipient,
        status: RequestStatus.pending,
        postfix: 'send',
        isRequester: false,
      );

      if (statusCode == 200) {
        _user.sentRequests.add(FriendRequest(
          requester: _user.username,
          recipient: recipient,
          status: RequestStatus.pending,
        ));
      }

      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest({required String requester}) async {
    if (!_user.friends.contains(requester)) {
      final statusCode = await _operateFriendRequest(
        username: requester,
        status: RequestStatus.accepted,
        postfix: 'accept',
        isRequester: true,
      );

      if (statusCode == 200) {
        _user.friends.add(requester);
        _user.receivedRequests
            .removeWhere((request) => request.requester == requester);
      }

      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest({required String requester}) async {
    if (!_user.friends.contains(requester)) {
      final statusCode = await _operateFriendRequest(
        username: requester,
        status: RequestStatus.rejected,
        postfix: 'reject',
        isRequester: true,
      );

      if (statusCode == 200) {
        _user.receivedRequests
            .removeWhere((request) => request.requester == requester);
      }

      notifyListeners();
    }
  }

  Future<void> cancelSentRequest({required String recipient}) async {
    if (_user.friends.contains(recipient)) {
      final statusCode = await _operateFriendRequest(
        username: recipient,
        status: RequestStatus.canceled,
        postfix: 'cancel',
        isRequester: false,
      );

      if (statusCode == 200) {
        _user.sentRequests
            .removeWhere((request) => request.recipient == recipient);
      }

      notifyListeners();
    }
  }

  Future<int> _operateFriendRequest({
    required String username,
    required RequestStatus status,
    required String postfix,
    required bool isRequester,
  }) async {
    return (await http.post(
      Uri.parse('$friendEndpoint/request/$postfix'),
      headers: {
        'Authorization': 'Basic ${_user.authToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requester': isRequester ? username : _user.username,
        'recipient': isRequester ? _user.username : username,
        'status': status.name.toUpperCase(),
      }),
    ))
        .statusCode;
  }
}
