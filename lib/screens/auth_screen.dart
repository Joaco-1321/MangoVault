import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/screens/home_screen.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen();

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final WebSocketService _socketManager;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _width = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppNameText(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: _width,
              child: TextField(
                controller: _usernameController,
                obscureText: false,
                decoration: const InputDecoration(labelText: 'username'),
              ),
            ),
            const SizedBox(height: 30.0),
            SizedBox(
              width: _width,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'password'),
              ),
            ),
            const SizedBox(height: 30.0),
            SizedBox(
              width: _width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    _socketManager = WebSocketService(
      username: username,
      password: password,
    );

    _socketManager.authenticate(
      username,
      password,
      (success) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(User(username), _socketManager),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('login failed'),
              content: const Text('invalid username or password'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ok'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
