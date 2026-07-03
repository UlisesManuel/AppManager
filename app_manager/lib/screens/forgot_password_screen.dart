import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final _idoloController = TextEditingController();
  final _comidaController = TextEditingController();
  final _padreController = TextEditingController();
  final _madreController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _idoloController.dispose();
    _comidaController.dispose();
    _padreController.dispose();
    _madreController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validarTexto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  String? _validarAnio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Ingrese un año válido';
    }

    return null;
  }

  Future<void> _recuperarCuenta() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {

      _showSnackBar(
        'Las contraseñas no coinciden.',
        Colors.redAccent,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final usuario =
          await DatabaseHelper.instance.validarPreguntasSeguridad(
        idolo: _idoloController.text,
        comida: _comidaController.text,
        padre: _padreController.text,
        madre: _madreController.text,
      );

      if (usuario == null) {

        setState(() {
          _isLoading = false;
        });

        _showSnackBar(
          'Las respuestas no coinciden.',
          Colors.redAccent,
        );

        return;
      }

      await DatabaseHelper.instance.actualizarPasswordMaestra(
        usuario['id'],
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Acceso recuperado'),
            ],
          ),
          content: const Text(
            'Tu contraseña maestra fue actualizada correctamente.\n\nAhora puedes iniciar sesión con tu nueva contraseña.',
          ),
          actions: [

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),

          ],
        ),
      );

    } catch (e) {

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Ocurrió un error durante la recuperación.',
        Colors.redAccent,
      );

    }
  }

  void _showSnackBar(
    String mensaje,
    Color color,
  ) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar acceso'),
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
                    Icons.security,
                    size: 90,
                    color: Colors.blueGrey,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Recuperar acceso',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Responde correctamente las cuatro preguntas de seguridad para establecer una nueva contraseña maestra.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _idoloController,
                    decoration: const InputDecoration(
                      labelText:
                          'Mi mayor ídolo o ejemplo a seguir',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarTexto,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _comidaController,
                    decoration: const InputDecoration(
                      labelText: 'Mi comida favorita',
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarTexto,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _padreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:
                          'Año de nacimiento de mi papá',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarAnio,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _madreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:
                          'Año de nacimiento de mi mamá',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarAnio,
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña maestra',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una contraseña';
                      }

                      if (value.length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_reset),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme la contraseña';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _recuperarCuenta,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Recuperar acceso',
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