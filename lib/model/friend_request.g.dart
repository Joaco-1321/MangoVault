// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      requester: json['requester'] as String,
      recipient: json['recipient'] as String,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'requester': instance.requester,
      'recipient': instance.recipient,
      'status': _$RequestStatusEnumMap[instance.status]!,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.canceled: 'CANCELED',
  RequestStatus.pending: 'PENDING',
  RequestStatus.accepted: 'ACCEPTED',
  RequestStatus.rejected: 'REJECTED',
};
