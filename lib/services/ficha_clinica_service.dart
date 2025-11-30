import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ficha_clinica.dart';

class FichaClinicaService {
  final _db = FirebaseFirestore.instance;

  Future<FichaClinica?> obtenerFicha({
    required String pacienteUid,
    required String psicoUid,
  }) async {
    final snap = await _db
        .collection('fichas_clinicas')
        .where('pacienteUid', isEqualTo: pacienteUid)
        .where('psicoUid', isEqualTo: psicoUid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    return FichaClinica.fromMap(
      snap.docs.first.data() as Map<String, dynamic>,
    );
  }

  Future<void> guardarFicha(FichaClinica ficha) async {
    // un doc por pareja paciente‑psico
    final docId = '${ficha.pacienteUid}_${ficha.psicoUid}';
    await _db.collection('fichas_clinicas').doc(docId).set(
          ficha.toMap(),
          SetOptions(merge: true),
        );
  }
}
