import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/sesion.dart';
import '../services/sesion_service.dart';

class ReservaSesionScreen extends StatefulWidget {
  final String psicoId;
  final String psicoNombre;
  final double tarifaOnline;
  final double tarifaPresencial;

  const ReservaSesionScreen({
    super.key,
    required this.psicoId,
    required this.psicoNombre,
    required this.tarifaOnline,
    required this.tarifaPresencial,
  });

  @override
  State<ReservaSesionScreen> createState() => _ReservaSesionScreenState();
}

class _ReservaSesionScreenState extends State<ReservaSesionScreen> {
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);
  String _modalidad = 'virtual';
  bool _cargando = false;

  final SesionService _sesionService = SesionService();

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null) {
      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  Future<void> _confirmarReserva() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para reservar')),
      );
      return;
    }

    final fecha = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
    );

    final double tarifaAplicada =
        _modalidad == 'virtual'
            ? widget.tarifaOnline
            : widget.tarifaPresencial;

    setState(() {
      _cargando = true;
    });

    try {
      final sesion = Sesion(
        id: '',
        psicoUid: widget.psicoId,
        pacienteUid: user.uid,
        fecha: fecha,
        modalidad: _modalidad,
        estado: 'pendiente',
        recordatorioProgramado: false,
        tarifaAplicada: tarifaAplicada,
      );

      await _sesionService.crearSesion(sesion);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión reservada con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reservar: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto =
        '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}';
    final horaTexto =
        '${_horaSeleccionada.hour.toString().padLeft(2, '0')}:'
        '${_horaSeleccionada.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva con ${widget.psicoNombre}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Modalidad'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _modalidad,
              items: const [
                DropdownMenuItem(
                  value: 'virtual',
                  child: Text('Online / virtual'),
                ),
                DropdownMenuItem(
                  value: 'presencial',
                  child: Text('Presencial'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _modalidad = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Fecha: $fechaTexto'),
            ElevatedButton(
              onPressed: _seleccionarFecha,
              child: const Text('Cambiar fecha'),
            ),
            const SizedBox(height: 16),
            Text('Hora: $horaTexto'),
            ElevatedButton(
              onPressed: _seleccionarHora,
              child: const Text('Cambiar hora'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _confirmarReserva,
              icon: const Icon(Icons.check),
              label: _cargando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
