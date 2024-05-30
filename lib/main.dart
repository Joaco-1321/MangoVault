import 'package:flutter/material.dart';
import 'package:mangovault/notifier/auth_mode_notifier.dart';
import 'package:mangovault/screens/auth_screen.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<WebSocketService>(
            create: (_) => WebSocketService(),
          ),
          ChangeNotifierProvider<AuthService>(
            create: (context) => AuthService(context.read<WebSocketService>()),
          ),
          ChangeNotifierProvider<FriendService>(
            create: (context) => FriendService(
              context.read<WebSocketService>(),
              context.read<AuthService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthModeNotifier(),
          )
        ],
        child: const MangoVault(),
      ),
    );

class MangoVault extends StatelessWidget {
  const MangoVault();

  @override
  Widget build(BuildContext context) {
    const title = 'MangoVault';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
    );
  }
}
