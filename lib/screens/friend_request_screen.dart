import 'package:flutter/material.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:provider/provider.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('manage friend requests'),
      ),
      body: Consumer<FriendService>(
        builder: (context, friendService, child) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'add friend',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      friendService.sendFriendRequest(
                        recipient: _usernameController.text.trim(),
                      );

                      _usernameController.clear();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('friend requests received'),
                    subtitle: Column(
                      children: friendService.receivedRequests
                          .map((request) => ListTile(
                                title: Text(request.requester),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () {
                                        friendService.acceptFriendRequest(
                                          requester: request.requester,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        friendService.rejectFriendRequest(
                                          requester: request.requester,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  ListTile(
                    title: const Text('friend requests sent'),
                    subtitle: Column(
                      children: friendService.sentRequests
                          .map((username) => ListTile(
                                title: Text(username.recipient),
                                trailing: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    friendService.cancelSentRequest(
                                      recipient: username.recipient,
                                    );
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
