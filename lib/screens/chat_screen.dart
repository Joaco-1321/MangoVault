import 'package:flutter/material.dart';
import 'package:mangovault/model/message.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/message_service.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String recipient;

  const ChatScreen(this.recipient, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat - ${widget.recipient}'),
      ),
      body: Consumer<MessageService>(
        builder: (context, messageService, child) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                );
              }
            },
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messageService.getMessages(widget.recipient).length,
                  itemBuilder: (context, index) {
                    final message = messageService.getMessages(widget.recipient)[index];

                    return Align(
                      alignment: message.sender == _authService.username!
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.sender == _authService.username!
                              ? Colors.blue
                              : Colors.grey,
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
                      onPressed: () {
                        final String message = _textController.text.trim();

                        if (message.isNotEmpty) {
                          messageService.sendMessage(
                            Message(
                              _authService.username!,
                              widget.recipient,
                              message,
                              DateTime.now(),
                            ),
                          );

                          _textController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
