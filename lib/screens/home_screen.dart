import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/services/notification_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User _user;

  const HomeScreen(this._user);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService = context.read<NotificationService>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final friends = widget._user.friends.toList();

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
                setState(() => widget._user.friends.remove(friends[index]));
              }
            }),
            // onTap: () => Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ChatScreen(
            //       username: widget._user.username,
            //       receiver: friendUsername,
            //       manager: widget.manager,
            //     ),
            //   ),
            // ),
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
        setState(() => widget._user.friends.add(username));
      }
    });
  }
}
