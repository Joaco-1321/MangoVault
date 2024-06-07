import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool sentByMe;

  const MessageBubble({
    required this.message,
    required this.sentByMe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        decoration: BoxDecoration(
          color: sentByMe ? Colors.orange[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: sentByMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
