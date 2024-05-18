import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final WebSocketService manager;

  const HomeScreen(this.user, this.manager, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final friends = widget.user.friends.toList();

    return Scaffold(
      appBar: AppBar(
        title: const AppNameText(),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friendUsername = friends[index];

          return ListTile(
            title: Text(friendUsername),
            onLongPress: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('remove friend?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('yes'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('no'),
                  )
                ],
              ),
            ).then((value) {
              if (value != null && value) {
                setState(() => widget.user.friends.remove(friends[index]));
              }
            }),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  username: widget.user.username,
                  receiver: friendUsername,
                  manager: widget.manager,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialogWithInput(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void showDialogWithInput(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('add a friend'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'enter their username here'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop<String>(controller.text.replaceAll(RegExp(r'\s'), '')),
            child: const Text('ok'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop<String>(''),
            child: const Text('cancel'),
          )
        ],
      ),
    ).then((value) {
      String? username = value as String?;
      if (username != null && username.isNotEmpty) {
        setState(() => widget.user.friends.add(username));
      }
    });
  }
}
