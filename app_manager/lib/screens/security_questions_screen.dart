import 'package:flutter/material.dart';
import 'package:app_manager/database/database_helper.dart';

class SecurityQuestionsScreen extends StatefulWidget {
  final int usuarioId;

  const SecurityQuestionsScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<SecurityQuestionsScreen> createState() =>
      _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState
    extends State<SecurityQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idoloController = TextEditingController();
  final _comidaController = TextEditingController();
  final _padreController = TextEditingController();
  final _madreController = TextEditingController();

  bool _guardando = false;

  @override
    void initState() {
        super.initState();
    _cargarPreguntas();
    }

  @override
  void dispose() {
    _idoloController.dispose();
    _comidaController.dispose();
    _padreController.dispose();
    _madreController.dispose();
    super.dispose();
  }

  Future<void> _cargarPreguntas() async {
    final usuario =
        await DatabaseHelper.instance.obtenerUsuarioPorId(widget.usuarioId);

    if (usuario == null) return;

    setState(() {
        _idoloController.text =
            usuario['respuesta_idolo'] ?? '';

        _comidaController.text =
            usuario['respuesta_comida'] ?? '';

        _padreController.text =
            usuario['respuesta_padre'] ?? '';

        _madreController.text =
            usuario['respuesta_madre'] ?? '';
    });
  }

  Future<void> _guardarPreguntas() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      await DatabaseHelper.instance.guardarPreguntasSeguridad(
        usuarioId: widget.usuarioId,
        idolo: _idoloController.text,
        comida: _comidaController.text,
        padre: _padreController.text,
        madre: _madreController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preguntas de seguridad guardadas correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas de seguridad'),
      ),
      body: SingleChildScrollView(
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

              const SizedBox(height: 15),

              const Text(
                'Estas respuestas te permitirán recuperar el acceso si olvidas tu contraseña maestra.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _idoloController,
                decoration: const InputDecoration(
                  labelText: 'Mi mayor ídolo o ejemplo a seguir',
                  border: OutlineInputBorder(),
                ),
                validator: _validarTexto,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _comidaController,
                decoration: const InputDecoration(
                  labelText: 'Mi comida favorita',
                  border: OutlineInputBorder(),
                ),
                validator: _validarTexto,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _padreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año de nacimiento de mi papá',
                  border: OutlineInputBorder(),
                ),
                validator: _validarAnio,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _madreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año de nacimiento de mi mamá',
                  border: OutlineInputBorder(),
                ),
                validator: _validarAnio,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarPreguntas,
                  child: _guardando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Guardar preguntas de seguridad',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}