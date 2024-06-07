import 'package:flutter/material.dart';
import 'package:mangovault/notifier/auth_notifier.dart';
import 'package:mangovault/screens/auth_screen.dart';
import 'package:mangovault/services/api_service.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/encryption_service.dart';
import 'package:mangovault/services/friend_service.dart';
import 'package:mangovault/services/key_service.dart';
import 'package:mangovault/services/message_service.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthNotifier(),
          ),
          Provider<WebSocketService>(
            create: (_) => WebSocketService(),
          ),
          ChangeNotifierProvider<AuthService>(
            create: (context) => AuthService(context.read<WebSocketService>()),
          ),
          Provider<ApiService>(
            create: (context) => ApiService(context.read<AuthService>()),
          ),
          Provider<KeyService>(
            create: (context) => KeyService(
              context.read<WebSocketService>(),
              context.read<ApiService>(),
            ),
          ),
          Provider<EncryptionService>(
            create: (context) => EncryptionService(
              context.read<KeyService>(),
            ),
          ),
          ChangeNotifierProvider<MessageService>(
            create: (context) => MessageService(
              context.read<WebSocketService>(),
              context.read<AuthService>(),
              context.read<EncryptionService>(),
            ),
          ),
          ChangeNotifierProvider<FriendService>(
            create: (context) => FriendService(
              context.read<WebSocketService>(),
              context.read<AuthService>(),
              context.read<ApiService>(),
            ),
          ),
        ],
        child: const MangoVault(),
      ),
    );

class MangoVault extends StatelessWidget {
  const MangoVault({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'MangoVault';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.orange.shade800,
          onPrimary: Colors.white,
          secondary: Colors.orangeAccent,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.orange.shade800,
          onPrimary: Colors.white,
          secondary: Colors.orangeAccent,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.black,
          surface: Colors.black12,
          onSurface: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
    );
  }
}
