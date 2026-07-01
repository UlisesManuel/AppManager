import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class PasswordDetailScreen extends StatefulWidget {
  final Map<String, dynamic> credential; // Fila completa de SQLite
  final int usuarioId;                    // ID de sesión activa

  const PasswordDetailScreen({
    super.key,
    required this.credential,
    required this.usuarioId,
  });

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool mostrarPassword = false;
  bool estaEditando = false;

  late TextEditingController siteController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos actuales de la credencial
    siteController = TextEditingController(text: widget.credential['nombre_servicio']);
    usernameController = TextEditingController(text: widget.credential['usuario_servicio']);
    passwordController = TextEditingController(text: widget.credential['password_servicio']);
  }

  @override
  void dispose() {
    siteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Pide la Contraseña Maestra y ejecuta una acción si es correcta
  void _verificarAccion(String titulo, Function actionSuccess) {
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: passController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Ingrese su contraseña maestra",
              labelText: "Contraseña Maestra",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final passwordMaestra = passController.text;
                // Validamos contra el usuario real en SQLite
                bool isValid = await DatabaseHelper.instance
                    .verificarPasswordMaestra(widget.usuarioId, passwordMaestra);

                if (mounted) Navigator.pop(context); // Cierra el diálogo

                if (isValid) {
                  actionSuccess(); // Ejecuta la acción protegida
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contraseña maestra incorrecta'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  // Guarda los cambios modificados en SQLite
  Future<void> _guardarCambiosEdicion() async {
    final Map<String, dynamic> updatedRow = {
      'id': widget.credential['id'],
      'usuario_id': widget.usuarioId,
      'nombre_servicio': siteController.text.trim(),
      'usuario_servicio': usernameController.text.trim(),
      'password_servicio': passwordController.text,
    };

    await DatabaseHelper.instance.updateCredential(updatedRow);
    setState(() {
      estaEditando = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente'), backgroundColor: Colors.green),
      );
    }
  }

  // Elimina el registro de SQLite
  Future<void> _eliminarCredencial() async {
    await DatabaseHelper.instance.deleteCredential(widget.credential['id']);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credencial eliminada'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context); // Vuelve al Home refrescando
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(estaEditando ? "Editar Credencial" : "Detalle de Credencial"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            
            // Campos dinámicos (Editables o Solo Lectura)
            TextFormField(
              controller: siteController,
              enabled: estaEditando,
              decoration: const InputDecoration(labelText: "Sitio o Aplicación", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: usernameController,
              enabled: estaEditando,
              decoration: const InputDecoration(labelText: "Usuario / Correo", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            if (estaEditando) ...[
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Nueva Contraseña", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {
                  _verificarAccion("Guardar Cambios", _guardarCambiosEdicion);
                },
                icon: const Icon(Icons.save),
                label: const Text("Confirmar y Guardar Cambios"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
              TextButton(
                onPressed: () => setState(() => estaEditando = false),
                child: const Text("Cancelar Edición"),
              ),
            ] else ...[
              const Text("Contraseña:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  mostrarPassword ? passwordController.text : "************",
                  style: const TextStyle(fontSize: 20, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 30),
              
              // Botones de acción protegidos
              ElevatedButton.icon(
                onPressed: () {
                  if (mostrarPassword) {
                    setState(() => mostrarPassword = false);
                  } else {
                    _verificarAccion("Ver Contraseña", () => setState(() => mostrarPassword = true));
                  }
                },
                icon: Icon(mostrarPassword ? Icons.visibility_off : Icons.visibility),
                label: Text(mostrarPassword ? "Ocultar Contraseña" : "Ver Contraseña"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _verificarAccion("Acceder a Edición", () => setState(() => estaEditando = true));
                },
                icon: const Icon(Icons.edit),
                label: const Text("Editar"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _verificarAccion("Eliminar Credencial", _eliminarCredencial);
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text("Eliminar"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}