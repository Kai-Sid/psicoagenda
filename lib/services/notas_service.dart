import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/nota_privada.dart';

class NotasService {
  final _db = FirebaseFirestore.instance;

  // Lee todas las notas de una sesión
  Stream<List<NotaPrivada>> notasDeSesion(String sesionId) {
    return _db
        .collection('notas_privadas')
        .where('sesionId', isEqualTo: sesionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => NotaPrivada.fromMap(
                  d.id,
                  d.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Agrega una nota nueva
  Future<void> agregarNota({
    required String sesionId,
    required String psicoUid,
    required String pacienteUid,
    required String contenido,
  }) async {
    final nota = NotaPrivada(
      id: '',
      sesionId: sesionId,
      psicoUid: psicoUid,
      pacienteUid: pacienteUid,
      contenido: contenido,
      createdAt: DateTime.now(),
    );

    await _db.collection('notas_privadas').add(nota.toMap());
  }
}
