enum RequestStatus { canceled, pending, accepted, rejected }

class FriendRequest {
  final String requester;
  final String recipient;
  final RequestStatus status;

  FriendRequest({
    required this.requester,
    required this.recipient,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requester: json['requester'],
      recipient: json['recipient'],
      status: RequestStatus.values
          .firstWhere((e) => e.name == json['status'].toString().toLowerCase()),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FriendRequest &&
      requester == other.requester &&
      recipient == other.recipient;
}
