import 'package:cloud_firestore/cloud_firestore.dart';

class NotaPrivada {
  final String id;
  final String sesionId;
  final String psicoUid;
  final String pacienteUid;
  final String contenido;
  final DateTime createdAt;

  NotaPrivada({
    required this.id,
    required this.sesionId,
    required this.psicoUid,
    required this.pacienteUid,
    required this.contenido,
    required this.createdAt,
  });

  factory NotaPrivada.fromMap(String id, Map<String, dynamic> data) {
    final createdRaw = data['createdAt'];
    DateTime created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else {
      created = DateTime.now();
    }

    return NotaPrivada(
      id: id,
      sesionId: (data['sesionId'] ?? '').toString(),
      psicoUid: (data['psicoUid'] ?? '').toString(),
      pacienteUid: (data['pacienteUid'] ?? '').toString(),
      contenido: (data['contenido'] ?? '').toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sesionId': sesionId,
      'psicoUid': psicoUid,
      'pacienteUid': pacienteUid,
      'contenido': contenido,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
