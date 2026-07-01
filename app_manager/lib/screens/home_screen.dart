import 'package:flutter/material.dart';
import 'package:app_manager/database/database_helper.dart';
import 'add_password_screen.dart';
import 'password_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final int usuarioId; // ID del usuario autenticado

  const HomeScreen({super.key, required this.usuarioId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _credentialsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCredentials();
  }

  // Consulta la base de datos de forma asíncrona
  void _refreshCredentials() {
    setState(() {
      _credentialsFuture = DatabaseHelper.instance.getCredentialsByUser(widget.usuarioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Contraseñas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCredentials,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _credentialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No tienes contraseñas guardadas.\n¡Presiona + para añadir una!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final credential = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.blue),
                  title: Text(credential["nombre_servicio"] ?? ''),
                  subtitle: Text(credential["usuario_servicio"] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Navegamos al detalle enviando el mapa completo de la credencial y el usuarioId
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordDetailScreen(
                          credential: credential,
                          usuarioId: widget.usuarioId,
                        ),
                      ),
                    );
                    _refreshCredentials(); // Refrescar al volver por si se editó o borró
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Vamos a añadir contraseña pasando el usuarioId
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPasswordScreen(usuarioId: widget.usuarioId),
            ),
          );
          _refreshCredentials(); // Refrescar lista al regresar de guardar
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}