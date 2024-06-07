import 'package:flutter/material.dart';
import 'package:mangovault/model/message.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/message_service.dart';
import 'package:mangovault/widgets/message_bubble_widget.dart';
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
        title: Text(
          'chat - ${widget.recipient}',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  itemCount:
                      messageService.getMessages(widget.recipient).length,
                  itemBuilder: (context, index) {
                    final message =
                        messageService.getMessages(widget.recipient)[index];

                    return MessageBubble(
                      message: messageService
                          .getMessages(widget.recipient)[index]
                          .message,
                      sentByMe: message.sender == _authService.username!,
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'send a message',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (text) => _sendMessage(
                          messageService,
                          text.trim(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => _sendMessage(
                        messageService,
                        _textController.text.trim(),
                      ),
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

  void _sendMessage(MessageService service, String message) {
    if (message.isNotEmpty) {
      service.sendMessage(
        Message(
          _authService.username!,
          widget.recipient,
          message,
          DateTime.now(),
        ),
      );

      _textController.clear();
    }
  }
}
