import 'package:cloud_firestore/cloud_firestore.dart';

class Sesion {
  final String id;
  final String psicoUid;
  final String pacienteUid;
  final DateTime fecha;
  final String modalidad;
  final String estado;
  final bool recordatorioProgramado;
  final double tarifaAplicada;

  Sesion({
    required this.id,
    required this.psicoUid,
    required this.pacienteUid,
    required this.fecha,
    required this.modalidad,
    required this.estado,
    required this.recordatorioProgramado,
    required this.tarifaAplicada,
  });

  factory Sesion.fromMap(String id, Map<String, dynamic> data) {
    final dynamic fechaRaw = data['fecha'];
    final fecha = (fechaRaw is Timestamp)
        ? fechaRaw.toDate()
        : DateTime.now();

    final dynamic tarifaRaw = data['tarifaAplicada'];
    final tarifa =
        tarifaRaw is num ? tarifaRaw.toDouble() : 0.0;

    return Sesion(
      id: id,
      psicoUid: (data['psicoUid'] ?? '').toString(),
      pacienteUid: (data['pacienteUid'] ?? '').toString(),
      fecha: fecha,
      modalidad: (data['modalidad'] ?? 'presencial').toString(),
      estado: (data['estado'] ?? 'pendiente').toString(),
      recordatorioProgramado:
          data['recordatorioProgramado'] is bool
              ? data['recordatorioProgramado'] as bool
              : false,
      tarifaAplicada: tarifa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psicoUid': psicoUid,
      'pacienteUid': pacienteUid,
      'fecha': Timestamp.fromDate(fecha),
      'modalidad': modalidad,
      'estado': estado,
      'recordatorioProgramado': recordatorioProgramado,
      'tarifaAplicada': tarifaAplicada,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
