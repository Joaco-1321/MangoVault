import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/screens/friend_request_screen.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User _user;

  const HomeScreen(this._user);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FriendService _friendService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _friendService = context.read<FriendService>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppNameText(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => FriendRequestScreen(widget._user)),
            ),
          ),
        ],
      ),
      body: Consumer<FriendService>(
        builder: (context, friendService, child) => ListView.builder(
          itemCount: friendService.friends.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(friendService.friends[index]),
            );
          },
        ),
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
        _friendService.sendFriendRequest(widget._user.username, username);
      }
    });
  }
}
