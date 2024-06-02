enum RequestStatus {
  canceled,
  pending,
  accepted,
  rejected,
}

class FriendRequest {
  final String requester;
  final String recipient;
  final RequestStatus status;

  FriendRequest({
    required this.requester,
    required this.recipient,
    required this.status,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) => FriendRequest(
        requester: map['requester'] as String,
        recipient: map['recipient'] as String,
        status: RequestStatus.values.firstWhere(
          (s) => s.name.toUpperCase() == map['status'],
        ),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'requester': requester,
        'recipient': recipient,
        'status': status.name.toUpperCase(),
      };

  @override
  bool operator ==(Object other) =>
      other is FriendRequest &&
      requester == other.requester &&
      recipient == other.recipient;
}
