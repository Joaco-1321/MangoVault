import 'package:json_annotation/json_annotation.dart';

part 'friend_request.g.dart';

enum RequestStatus {
  @JsonValue('CANCELED')
  canceled,
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
}

@JsonSerializable()
class FriendRequest {
  final String requester;
  final String recipient;
  final RequestStatus status;

  FriendRequest({
    required this.requester,
    required this.recipient,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  @override
  bool operator ==(Object other) =>
      other is FriendRequest &&
      requester == other.requester &&
      recipient == other.recipient;
}
