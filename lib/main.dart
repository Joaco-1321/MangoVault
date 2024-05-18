import 'package:flutter/material.dart';
import 'package:mangovault/screens/auth_screen.dart';

void main() => runApp(const MangoVault());

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
