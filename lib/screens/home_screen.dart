import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/screens/friend_request_screen.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/services/message_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  builder: (context) => const FriendRequestScreen()),
            ),
          ),
        ],
      ),
      body: Consumer2<FriendService, MessageService>(
        builder: (
          context,
          friendService,
          messageService,
          child,
        ) {
          final friends = friendService.friends;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(friends[index]),
              subtitle: Text(
                messageService.getMessages(friends[index]).isNotEmpty
                    ? messageService.getMessages(friends[index]).last.message
                    : '',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(friends[index]),
                ),
              ),
              onLongPress: () => confirmationDialog(
                friends[index],
                friendService.removeFriend,
              ),
            ),
          );
        },
      ),
    );
  }

  void confirmationDialog(String friend, Function(String) remove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('remove friend'),
        content: Text('do you want to remove $friend from your friends?'),
        actions: [
          TextButton(
            onPressed: () {
              remove(friend);
              Navigator.pop(context);
            },
            child: const Text('yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('no'),
          ),
        ],
      ),
    );
  }
}
