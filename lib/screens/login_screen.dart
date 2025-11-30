import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _esRegistro = true;
  String _rolSeleccionado = 'cliente';
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      if (_esRegistro) {
        await _authService.registrarUsuario(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          telefono: _telefonoController.text.trim(),
          password: _passwordController.text.trim(),
          rol: _rolSeleccionado,
        );
      } else {
        await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // No usamos setState aquí: AuthWrapper detecta el cambio de usuario
      // y navega automáticamente a la pantalla correspondiente.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_esRegistro)
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Correo inválido' : null,
              ),
              const SizedBox(height: 12),
              if (_esRegistro)
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.length < 7 ? 'Teléfono inválido' : null,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 12),
              if (_esRegistro)
                DropdownButtonFormField<String>(
                  value: _rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'cliente',
                      child: Text('Paciente'),
                    ),
                    DropdownMenuItem(
                      value: 'psicologo',
                      child: Text('Psicólogo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _rolSeleccionado = value;
                      });
                    }
                  },
                ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _cargando ? null : _enviar,
                child: _cargando
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(_esRegistro ? 'Registrarse' : 'Entrar'),
              ),
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    _esRegistro = !_esRegistro;
                  });
                },
                child: Text(
                  _esRegistro
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
