import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'models/usuario.dart';
import 'screens/login_screen.dart';
import 'screens/home_paciente_screen.dart';
import 'screens/home_psico_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PsicoAgendaApp());
}

class PsicoAgendaApp extends StatelessWidget {
  const PsicoAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsicoAgenda',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<Usuario?>(
          future: auth.getUsuarioActual(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final usuario = snap.data;
            if (usuario == null) {
              return const LoginScreen();
            }

            if (usuario.rol == 'psicologo') {
              return HomePsicoScreen(usuario: usuario);
            } else {
              return HomePacienteScreen(usuario: usuario);
            }
          },
        );
      },
    );
  }
}
