import 'package:flutter/material.dart';
import 'dart:math';
import '../database/database_helper.dart'; // Asegura la ruta de tu DB

class AddPasswordScreen extends StatefulWidget {
  final int usuarioId; // Recibe el ID del usuario logueado

  const AddPasswordScreen({super.key, required this.usuarioId});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController siteController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool ocultarPassword = true;
  bool ocultarConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    siteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String generarPassword() {
    const caracteres =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    Random random = Random();
    return List.generate(
      12,
      (index) => caracteres[random.nextInt(caracteres.length)],
    ).join();
  }

  Future<void> _guardarCredencial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Mapeo exacto con los nombres de columna de tu tabla 'credenciales'
    final Map<String, dynamic> credentialRow = {
      'usuario_id': widget.usuarioId,
      'nombre_servicio': siteController.text.trim(),
      'usuario_servicio': usernameController.text.trim(),
      'password_servicio': passwordController.text,
    };

    try {
      await DatabaseHelper.instance.insertCredential(credentialRow);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña guardada con éxito'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Regresa al Home refrescando la lista
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la credencial'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Contraseña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: siteController,
                decoration: const InputDecoration(
                  labelText: "Nombre del sitio o aplicación",
                  prefixIcon: Icon(Icons.apps),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Ingrese el nombre del sitio' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Ingrese el usuario del servicio' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: passwordController,
                obscureText: ocultarPassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarPassword = !ocultarPassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value == null || value.isEmpty 
                    ? 'Ingrese la contraseña' : null,
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      passwordController.text = generarPassword();
                    });
                  },
                  icon: const Icon(Icons.password),
                  label: const Text("Generar Contraseña"),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: ocultarConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarConfirmPassword = !ocultarConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirme la contraseña';
                  if (value != passwordController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCredencial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Guardar", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}