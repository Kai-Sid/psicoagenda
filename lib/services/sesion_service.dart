import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sesion.dart';

class SesionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearSesion(Sesion sesion) async {
    await _db.collection('sesiones').add(sesion.toMap());
  }

  Stream<List<Sesion>> sesionesDePsicologo({
    required String psicoUid,
  }) {

  print('SESIONES PARA UID: $psicoUid');

    return _db
        .collection('sesiones')
        .where('psicoUid', isEqualTo: psicoUid)
        .orderBy('fecha')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Sesion.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }
    Future<void> actualizarEstado({
      required String sesionId,
      required String nuevoEstado,
    }) async {
      await _db.collection('sesiones').doc(sesionId).update({
        'estado': nuevoEstado,
      });
    }

}

