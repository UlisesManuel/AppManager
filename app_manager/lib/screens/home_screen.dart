import 'package:flutter/material.dart';
import 'add_password_screen.dart';
import 'password_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> passwords = [
      {
        "app": "Facebook",
        "user": "usuario@gmail.com",
      },
      {
        "app": "Instagram",
        "user": "ulises123",
      },
      {
        "app": "GitHub",
        "user": "UlisesManuel",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Contraseñas"),
      ),
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: Text(passwords[index]["app"]!),
              subtitle: Text(passwords[index]["user"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => PasswordDetailScreen(
                    appName: passwords[index]["app"]!,
                    username: passwords[index]["user"]!,
                ),
                ),
            );
            },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPasswordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}