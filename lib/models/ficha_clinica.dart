import 'package:cloud_firestore/cloud_firestore.dart';

class FichaClinica {
  final String pacienteUid;
  final String psicoUid;
  final String motivoConsulta;
  final String antecedentes;
  final String objetivos;
  final List<String> documentosUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FichaClinica({
    required this.pacienteUid,
    required this.psicoUid,
    required this.motivoConsulta,
    required this.antecedentes,
    required this.objetivos,
    required this.documentosUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory FichaClinica.fromMap(Map<String, dynamic> data) {
    final createdRaw = data['createdAt'];
    final updatedRaw = data['updatedAt'];

    return FichaClinica(
      pacienteUid: (data['pacienteUid'] ?? '').toString(),
      psicoUid: (data['psicoUid'] ?? '').toString(),
      motivoConsulta: (data['motivoConsulta'] ?? '').toString(),
      antecedentes: (data['antecedentes'] ?? '').toString(),
      objetivos: (data['objetivos'] ?? '').toString(),
      documentosUrls: (data['documentosUrls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: createdRaw is Timestamp ? createdRaw.toDate() : DateTime.now(),
      updatedAt: updatedRaw is Timestamp ? updatedRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pacienteUid': pacienteUid,
      'psicoUid': psicoUid,
      'motivoConsulta': motivoConsulta,
      'antecedentes': antecedentes,
      'objetivos': objetivos,
      'documentosUrls': documentosUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
