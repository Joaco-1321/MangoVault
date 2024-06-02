import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/chat_screen.dart';
import 'package:mangovault/screens/friend_request_screen.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/services/message_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User _user;

  const HomeScreen(this._user);

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
                  builder: (context) => FriendRequestScreen(widget._user)),
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
        ) =>
            ListView.builder(
          itemCount: friendService.friends.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(friendService.friends[index]),
            subtitle: Text(
              messageService.messages(friendService.friends[index]).isNotEmpty
                  ? messageService
                      .messages(friendService.friends[index])
                      .last
                      .message
                  : '',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                    username: widget._user.username,
                    recipient: friendService.friends[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
