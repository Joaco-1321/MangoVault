import 'package:flutter/material.dart';
import 'package:mangovault/screens/login_screen.dart';

void main() => runApp(const MangoVault());

class MangoVault extends StatelessWidget {
  const MangoVault({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'MangoVault';

    return MaterialApp(
      title: title,
      home: LoginScreen(key: key),
    );
  }
}
