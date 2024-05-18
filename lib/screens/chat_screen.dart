import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:mangovault/model/message.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String receiver;
  final WebSocketService manager;

  const ChatScreen({
    required this.username,
    required this.receiver,
    required this.manager,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <Message>[];

  @override
  void initState() {
    super.initState();

    widget.manager.setCallback(
      (message) => updateChat(
        Message(
          jsonDecode(message)['message'],
          false,
        ),
      ),
    );

    widget.manager.markReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat - ${widget.receiver}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.isMine ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      message.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:
                        const InputDecoration(labelText: 'send a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      updateChat(Message(message, true));

      _textController.clear();

      widget.manager.sendMessage(
        jsonEncode({
          'from': widget.username,
          'to': widget.receiver,
          'message': message,
        }),
      );
    }
  }

  void updateChat(Message message) {
    setState(() => _messages.add(message));

    Timer(
      const Duration(milliseconds: 100),
      () =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
