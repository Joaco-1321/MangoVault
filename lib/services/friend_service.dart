import 'dart:convert';

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
  final ApiService _apiService;

  late final User _user;

  FriendService(this._webSocketService, this._authService, this._apiService) {
    _init();
  }

  List<String> get friends => _user.friends;

  List<FriendRequest> get sentRequests => _user.sentRequests;

  List<FriendRequest> get receivedRequests => _user.receivedRequests;

  Future<void> removeFriend(String friend) async {
    if (_user.friends.contains(friend)) {
      int statusCode = 400;

      await _apiService.delete(
        '$friendEndpoint/$friend',
        (response) => statusCode = response.statusCode,
      );

      if (statusCode == 200) {
        friends.remove(friend);
        notifyListeners();
      }
    }
  }

  Future<void> sendFriendRequest({required String recipient}) async {
    if (!_user.friends.contains(recipient) &&
        sentRequests
            .where((request) => request.recipient == recipient)
            .isEmpty &&
        receivedRequests
            .where((request) => request.requester == recipient)
            .isEmpty &&
        _user.username != recipient) {
      final statusCode = await _operateFriendRequest(
        username: recipient,
        status: RequestStatus.pending,
        postfix: 'send',
        isRequester: false,
      );

      if (statusCode == 200) {
        sentRequests.add(FriendRequest(
          requester: _user.username,
          recipient: recipient,
          status: RequestStatus.pending,
        ));
      }

      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest({required String requester}) async {
    if (!friends.contains(requester) && _user.username != requester) {
      final statusCode = await _operateFriendRequest(
        username: requester,
        status: RequestStatus.accepted,
        postfix: 'accept',
        isRequester: true,
      );

      if (statusCode == 200) {
        friends.add(requester);
        receivedRequests
            .removeWhere((request) => request.requester == requester);
      }

      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest({required String requester}) async {
    if (!friends.contains(requester) && _user.username != requester) {
      final statusCode = await _operateFriendRequest(
        username: requester,
        status: RequestStatus.rejected,
        postfix: 'reject',
        isRequester: true,
      );

      if (statusCode == 200) {
        receivedRequests
            .removeWhere((request) => request.requester == requester);
      }

      notifyListeners();
    }
  }

  Future<void> cancelSentRequest({required String recipient}) async {
    if (!friends.contains(recipient) && _user.username != recipient) {
      final statusCode = await _operateFriendRequest(
        username: recipient,
        status: RequestStatus.canceled,
        postfix: 'cancel',
        isRequester: false,
      );

      if (statusCode == 200) {
        sentRequests.removeWhere((request) => request.recipient == recipient);
      }

      notifyListeners();
    }
  }

  Future<void> _init() async {
    _user = _authService.user!;

    await _apiService.get(
      friendEndpoint,
      (response) => friends.addAll(
        (json.decode(response.body) as List<dynamic>).cast(),
      ),
    );

    await _apiService.get(
      '$friendEndpoint/request',
      (response) {
        _user.addFriendRequests((json.decode(response.body) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((request) => FriendRequest.fromMap(request))
            .where((request) => request.status == RequestStatus.pending)
            .toList());
      },
    );

    _webSocketService.subscribe(
      "/user/queue/notification/request",
      (frame) {
        final requestReceived = FriendRequest.fromMap(jsonDecode(frame.body!));

        switch (requestReceived.status) {
          case RequestStatus.pending:
            _user.addFriendRequest(requestReceived);
          case RequestStatus.accepted:
            friends.add(requestReceived.recipient);
            sentRequests.removeWhere(
              (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.rejected:
            sentRequests.removeWhere(
              (request) => request.recipient == requestReceived.recipient,
            );
          case RequestStatus.canceled:
            receivedRequests.removeWhere(
              (request) => request.requester == requestReceived.requester,
            );
        }

        notifyListeners();
      },
    );

    _webSocketService.subscribe(
      "/user/queue/notification/remove",
          (frame) {
        friends.remove(frame.body);

        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<int> _operateFriendRequest({
    required String username,
    required RequestStatus status,
    required String postfix,
    required bool isRequester,
  }) async {
    int statusCode = 400;

    await _apiService.post(
        '$friendEndpoint/request/$postfix',
        json.encode({
          'requester': isRequester ? username : _user.username,
          'recipient': isRequester ? _user.username : username,
          'status': status.name.toUpperCase(),
        }),
        callback: (response) => statusCode = response.statusCode,
        headers: {
          'Content-Type': 'application/json',
        });

    return statusCode;
  }
}
