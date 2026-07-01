import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AppManager());
}

class AppManager extends StatelessWidget {
  const AppManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Manager',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}