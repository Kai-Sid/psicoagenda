import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reserva_sesion_screen.dart';

class ListaPsicologosScreen extends StatelessWidget {
  const ListaPsicologosScreen({super.key});

  List<String> asStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Psicólogos disponibles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('usuarios')
            .where('rol', isEqualTo: 'psicologo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuarios = snapshot.data?.docs ?? [];
          if (usuarios.isEmpty) {
            return const Center(
              child: Text('No hay psicólogos registrados'),
            );
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final uDoc = usuarios[index];
              final uData = uDoc.data() as Map<String, dynamic>;
              final uid = uDoc.id;
              final nombre =
                  (uData['nombre'] ?? '').toString().isEmpty
                      ? 'Psicólogo'
                      : uData['nombre'].toString();

              return FutureBuilder<DocumentSnapshot>(
                future: db.collection('psicologos').doc(uid).get(),
                builder: (context, snapPsico) {
                  if (!snapPsico.hasData) {
                    return ListTile(
                      title: Text(nombre),
                      subtitle: const Text('Cargando datos...'),
                    );
                  }

                  final pData =
                      snapPsico.data!.data() as Map<String, dynamic>? ?? {};

                  final bio = pData['bio']?.toString() ?? '';
                  final especialidades =
                      asStringList(pData['especialidad']);
                  final modalidades =
                      asStringList(pData['modalidades']);
                  final tarifaOnline =
                      (pData['tarifaOnline'] as num?)?.toDouble() ?? 0.0;
                  final tarifaPresencial =
                      (pData['tarifaPresencial'] as num?)?.toDouble() ?? 0.0;

                  final lineas = <String>[];
                  if (bio.isNotEmpty) {
                    lineas.add('Bio: $bio');
                  }
                  if (especialidades.isNotEmpty) {
                    lineas.add(
                        'Especialidades: ${especialidades.join(', ')}');
                  }
                  if (modalidades.isNotEmpty) {
                    lineas.add(
                        'Modalidades: ${modalidades.join(', ')}');
                  }
                  lineas.add(
                    'Online: S/ ${tarifaOnline.toStringAsFixed(2)} · '
                    'Presencial: S/ ${tarifaPresencial.toStringAsFixed(2)}',
                  );

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.psychology_alt),
                      title: Text(nombre),
                      subtitle: Text(lineas.join('\n')),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservaSesionScreen(
                              psicoId: uid,
                              psicoNombre: nombre,
                              tarifaOnline: tarifaOnline,
                              tarifaPresencial: tarifaPresencial,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
