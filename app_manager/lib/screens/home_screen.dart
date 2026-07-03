import 'package:flutter/material.dart';
import 'package:app_manager/database/database_helper.dart';
import 'add_password_screen.dart';
import 'password_detail_screen.dart';
import 'security_questions_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int usuarioId;

  const HomeScreen({
    super.key,
    required this.usuarioId,
  });

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

  void _refreshCredentials() {
    setState(() {
      _credentialsFuture =
          DatabaseHelper.instance.getCredentialsByUser(widget.usuarioId);
    });
  }

  IconData _obtenerIconoServicio(String nombre) {
    final servicio = nombre.toLowerCase();

    if (servicio.contains('google') || servicio.contains('gmail')) {
      return Icons.language;
    }

    if (servicio.contains('facebook')) {
      return Icons.facebook;
    }

    if (servicio.contains('instagram')) {
      return Icons.camera_alt;
    }

    if (servicio.contains('spotify')) {
      return Icons.music_note;
    }

    if (servicio.contains('netflix')) {
      return Icons.movie;
    }

    if (servicio.contains('steam')) {
      return Icons.sports_esports;
    }

    if (servicio.contains('discord')) {
      return Icons.forum;
    }

    if (servicio.contains('amazon')) {
      return Icons.shopping_cart;
    }

    if (servicio.contains('github')) {
      return Icons.code;
    }

    return Icons.lock_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Contraseñas"),
        actions: [
          IconButton(
            tooltip: "Actualizar",
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCredentials,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Agregar contraseña",
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPasswordScreen(
                usuarioId: widget.usuarioId,
              ),
            ),
          );

          _refreshCredentials();
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              24,
            ),
            color: Colors.indigo,
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Mis Contraseñas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Gestiona tus credenciales de forma segura.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _credentialsFuture,               builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                final list = snapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [

                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        18,
                        20,
                        18,
                        10,
                      ),
                      child: Text(
                        "Seguridad",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.green.shade100,
                          child: const Icon(
                            Icons.verified_user,
                            color: Colors.green,
                          ),
                        ),
                        title: const Text(
                          "Preguntas de seguridad",
                        ),
                        subtitle: const Text(
                          "Recupera el acceso si olvidas tu contraseña.",
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SecurityQuestionsScreen(
                                usuarioId:
                                    widget.usuarioId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.orange.shade100,
                          child: const Icon(
                            Icons.manage_accounts,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text(
                          "Cambiar datos de la cuenta",
                        ),
                        subtitle: const Text(
                          "Usuario, correo y contraseña.",
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(
                                usuarioId:
                                    widget.usuarioId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        18,
                        22,
                        18,
                        10,
                      ),
                      child: Text(
                        "Contraseñas guardadas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (list.isEmpty)

                      const Padding(
                        padding: EdgeInsets.all(25),
                        child: Center(
                          child: Column(
                            children: [

                              Icon(
                                Icons.lock_outline,
                                size: 70,
                                color: Colors.grey,
                              ),

                              SizedBox(height: 15),

                              Text(
                                "Aún no tienes contraseñas guardadas.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "Presiona el botón + para agregar la primera.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    else

                      ...list.map((credential) {

                        return Card(
                          child: ListTile(

                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.indigo.shade100,
                              child: Icon(
                                _obtenerIconoServicio(
                                  credential[
                                          "nombre_servicio"] ??
                                      "",
                                ),
                                color: Colors.indigo,
                              ),
                            ),

                            title: Text(
                              credential[
                                      "nombre_servicio"] ??
                                  "",
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                      top: 4),
                              child: Text(
                                credential[
                                        "usuario_servicio"] ??
                                    "",
                              ),
                            ),

                            trailing: const Icon(
                              Icons.chevron_right,
                            ),

                            onTap: () async {

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PasswordDetailScreen(
                                    credential:
                                        credential,
                                    usuarioId:
                                        widget
                                            .usuarioId,
                                  ),
                                ),
                              );

                              _refreshCredentials();

                            },
                          ),
                        );

                      }),

                  ],
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}