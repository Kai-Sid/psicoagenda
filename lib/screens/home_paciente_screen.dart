import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'lista_psicologos_screen.dart';
import 'mis_sesiones_paciente_screen.dart';

class HomePacienteScreen extends StatelessWidget {
  final Usuario usuario;
  const HomePacienteScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PsicoAgenda - Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.psychology),
              label: const Text('Buscar psicólogos y reservar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListaPsicologosScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Ver mis sesiones'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MisSesionesPacienteScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
