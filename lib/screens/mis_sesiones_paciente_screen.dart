import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/sesion.dart';

class MisSesionesPacienteScreen extends StatelessWidget {
  const MisSesionesPacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión para ver tus citas'),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis sesiones'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sesiones')
            .where('pacienteUid', isEqualTo: uid)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Aún no tienes sesiones reservadas'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data() as Map<String, dynamic>;

              final sesion = Sesion.fromMap(d.id, data);

              final fecha = sesion.fecha;
              final fechaTexto =
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year} '
                  '${fecha.hour.toString().padLeft(2, '0')}:'
                  '${fecha.minute.toString().padLeft(2, '0')}';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text('$fechaTexto - ${sesion.modalidad}'),
                  subtitle: Text(
                    'Estado: ${sesion.estado} · '
                    'Tarifa: S/ ${sesion.tarifaAplicada.toStringAsFixed(2)}',
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
