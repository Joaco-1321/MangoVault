import 'friend_request.dart';

class User {
  final String username;
  final String authToken;
  final List<String> _friends = [];
  final List<FriendRequest> _receivedRequests = [];
  final List<FriendRequest> _sentRequests = [];

  User(this.username, this.authToken);

  List<String> get friends => _friends;

  List<FriendRequest> get receivedRequests => _receivedRequests;

  List<FriendRequest> get sentRequests => _sentRequests;

  void addFriendRequests(List<FriendRequest> requests) {
    for (var request in requests) {
      addFriendRequest(request);
    }
  }

  void addFriendRequest(FriendRequest request) {
    if (request.recipient == username) {
      _receivedRequests.add(request);
    } else {
      _sentRequests.add(request);
    }
  }
}
