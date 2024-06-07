import 'package:flutter/material.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/screens/friend_request_screen.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/services/message_service.dart';
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
        title: Text(
          'MangoVault',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
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
            itemBuilder: (context, index) {
              final friend = friends[index];
              final messages = messageService.getMessages(friend);
              final lastMessage = messages.isNotEmpty ? messages.last : null;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    friend[0].toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                title: Text(
                  friend,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  lastMessage?.message ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => confirmationDialog(
                    friends[index],
                    friendService.removeFriend,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(friends[index]),
                  ),
                ),
              );
            },
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
