import 'package:flutter/material.dart';
import 'package:mangovault/model/user.dart';
import 'package:mangovault/notifier/auth_mode_notifier.dart';
import 'package:mangovault/screens/home_screen.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/widgets/app_name_text.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen();

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _width = 200.0;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService = context.read<AuthService>();
      _authService.addListener(_authListener);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authService.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authModeNotifier = context.watch<AuthModeNotifier>();

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
            if (!authModeNotifier.isLogin)
              SizedBox(
                width: _width,
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'repeat password'),
                ),
              ),
            if (!authModeNotifier.isLogin) const SizedBox(height: 30.0),
            SizedBox(
              width: _width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (authModeNotifier.isLogin) {
                        _authService.authenticate(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      } else {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('passwords do not match')),
                          );

                          return;
                        }

                        _authService.register(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    child: Text(
                      authModeNotifier.isLogin ? 'login' : 'register',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            TextButton(
              onPressed: () => authModeNotifier.toggleAuthMode(),
              child: Text(
                authModeNotifier.isLogin
                    ? "don't have an account? register"
                    : 'already have an account? login',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _authListener() {
    if (_authService.isAuthenticated) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         HomeScreen(User(_usernameController.text), _socketManager),
      //   ),
      // );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('success'),
          content: Text(_authService.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ok'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('failed'),
          content: Text(_authService.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ok'),
            ),
          ],
        ),
      );
    }
  }

  void login() {
    _authService.authenticate(
      _usernameController.text,
      _passwordController.text,
    );
  }
}
