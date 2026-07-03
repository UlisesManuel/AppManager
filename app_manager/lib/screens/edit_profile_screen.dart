import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final int usuarioId;

  const EditProfileScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {

    final usuario =
        await DatabaseHelper.instance.obtenerUsuarioPorId(
      widget.usuarioId,
    );

    if (usuario != null) {
      _usernameController.text = usuario["username"] ?? "";
      _emailController.text = usuario["email"] ?? "";
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {

    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty) {

      if (_newPasswordController.text !=
          _confirmPasswordController.text) {

        _mostrarSnackBar(
          "Las nuevas contraseñas no coinciden.",
          Colors.red,
        );

        return;
      }
    }

    setState(() {
      _saving = true;
    });

    final passwordCorrecta =
        await DatabaseHelper.instance.verificarPasswordMaestra(
      widget.usuarioId,
      _currentPasswordController.text,
    );

    if (!passwordCorrecta) {

      setState(() {
        _saving = false;
      });

      _mostrarSnackBar(
        "La contraseña actual es incorrecta.",
        Colors.red,
      );

      return;
    }

    try {

      await DatabaseHelper.instance.actualizarPerfilUsuario(
        usuarioId: widget.usuarioId,
        nuevoUsername:
            _usernameController.text.trim(),
        nuevoEmail:
            _emailController.text.trim(),
        nuevaPassword:
            _newPasswordController.text,
      );

      if (!mounted) return;

      _mostrarSnackBar(
        "Datos actualizados correctamente.",
        Colors.green,
      );

      Navigator.pop(context);

    } catch (e) {

      _mostrarSnackBar(
        "Ocurrió un error al actualizar.",
        Colors.red,
      );

    } finally {

      if (mounted) {
        setState(() {
          _saving = false;
        });
      }

    }

  }

  void _mostrarSnackBar(
      String mensaje,
      Color color) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
      return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar datos de la cuenta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.manage_accounts,
                    size: 90,
                    color: Colors.blueGrey,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Modificar datos de la cuenta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Puedes cambiar tu nombre de usuario, correo electrónico o contraseña. Para guardar los cambios debes ingresar tu contraseña actual.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa un nombre de usuario';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa un correo';
                      }

                      if (!value.contains('@')) {
                        return 'Correo inválido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  const Divider(),

                  const SizedBox(height: 15),

                  const Text(
                    'Cambiar contraseña (opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: Icon(Icons.lock_reset),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Divider(),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: Icon(Icons.verified_user),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes ingresar tu contraseña actual';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _guardarCambios,
                      child: _saving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}