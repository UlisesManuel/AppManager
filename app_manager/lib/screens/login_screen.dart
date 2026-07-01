import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
// Ruta exacta según tu estructura de carpetas
import 'package:app_manager/database/database_helper.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controladores para capturar el texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Clave global para la validación del formulario de Flutter
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberamos los controladores para evitar fugas de memoria
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica principal: Validación en SQLite y control de acceso
  Future<void> _handleLogin() async {
    // Si los campos de texto no pasan la validación visual, no hace nada
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Muestra el círculo de carga y desactiva el botón
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // 3. Consulta directa a tu base de datos SQLite real
      final user = await DatabaseHelper.instance.login(email, password);

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        final int usuarioId = user['id']; // Capturamos el id del mapa
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(usuarioId: usuarioId), // <-- Lo enviamos aquí
            ),
          );
        }
      } else {
        // 4. Las credenciales no coinciden en la base de datos (retornó null)
        _showErrorSnackBar('Correo o contraseña maestra incorrectos');
      }

      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al conectar con la base de datos local');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Manager'),
      ),
      // SingleChildScrollView evita el error de desbordamiento de píxeles al abrir el teclado
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline, 
                    size: 100, 
                    color: Colors.blueGrey
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // Campo: Correo Electrónico
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
                        return 'Por favor, ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un formato de correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Campo: Contraseña Maestra
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña maestra',
                      prefixIcon: Icon(Icons.password_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),

                  // Botón de acción con indicador de carga
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Iniciar Sesión', 
                              style: TextStyle(fontSize: 16)
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen()
                        ),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
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