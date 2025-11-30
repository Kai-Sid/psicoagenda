import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/sesion_service.dart';
import '../models/sesion.dart';
import 'notas_sesion_screen.dart';
import 'ficha_clinica_screen.dart';

class HomePsicoScreen extends StatelessWidget {
  final Usuario usuario;
  const HomePsicoScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final sesionService = SesionService();

    print('HOME PSICO UID: ${usuario.uid}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Sesion>>(
        stream: sesionService.sesionesDePsicologo(
          psicoUid: usuario.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sesiones = snapshot.data ?? [];
          if (sesiones.isEmpty) {
            return const Center(
              child: Text('No hay sesiones registradas'),
            );
          }

          return ListView.builder(
            itemCount: sesiones.length,
            itemBuilder: (context, index) {
              final s = sesiones[index];
              final fechaTexto =
                  '${s.fecha.day}/${s.fecha.month}/${s.fecha.year} '
                  '${s.fecha.hour.toString().padLeft(2, '0')}:'
                  '${s.fecha.minute.toString().padLeft(2, '0')}';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.event, color: Colors.black87),
                  ),
                  title: Text(
                    '$fechaTexto - ${s.modalidad}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Estado: ${s.estado} · '
                      'Tarifa: S/ ${s.tarifaAplicada.toStringAsFixed(2)}',
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotasSesionScreen(sesion: s),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.receipt_long),
                        tooltip: 'Ficha clínica',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FichaClinicaScreen(
                                pacienteUid: s.pacienteUid,
                                psicoUid: s.psicoUid,
                              ),
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          await sesionService.actualizarEstado(
                            sesionId: s.id,
                            nuevoEstado: value,
                          );
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'pendiente',
                            child: Text('Marcar como pendiente'),
                          ),
                          PopupMenuItem(
                            value: 'confirmada',
                            child: Text('Marcar como confirmada'),
                          ),
                          PopupMenuItem(
                            value: 'completada',
                            child: Text('Marcar como completada'),
                          ),
                          PopupMenuItem(
                            value: 'cancelada',
                            child: Text('Marcar como cancelada'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
