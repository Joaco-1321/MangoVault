class Message {
  final String sender;
  final String recipient;
  final String message;
  final DateTime timestamp;

  Message(this.sender, this.recipient, this.message, this.timestamp);

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        map['sender'] as String,
        map['recipient'] as String,
        map['message'] as String,
        DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'sender': sender,
        'recipient': recipient,
        'message': message,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}
