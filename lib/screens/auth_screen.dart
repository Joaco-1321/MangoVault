import 'package:flutter/material.dart';
import 'package:mangovault/notifier/auth_notifier.dart';
import 'package:mangovault/screens/home_screen.dart';
import 'package:mangovault/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _width = 300.0;

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
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MangoVault',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _width,
                child: TextField(
                  controller: _usernameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: _width,
                child: TextField(
                  controller: _passwordController,
                  obscureText: !authNotifier.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authNotifier.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: authNotifier.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              if (!authNotifier.isLogin)
                SizedBox(
                  width: _width,
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: !authNotifier.isRepeatPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'repeat password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          authNotifier.isRepeatPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: authNotifier.toggleRepeatPasswordVisibility,
                      ),
                    ),
                  ),
                ),
              if (!authNotifier.isLogin) const SizedBox(height: 20.0),
              SizedBox(
                width: _width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        if (authNotifier.isLogin) {
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
                        authNotifier.isLogin ? 'login' : 'register',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),
              TextButton(
                onPressed: () => authNotifier.toggleAuthMode(),
                child: Text(
                  authNotifier.isLogin
                      ? "don't have an account? register"
                      : 'already have an account? login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _authListener() {
    if (_authService.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
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
