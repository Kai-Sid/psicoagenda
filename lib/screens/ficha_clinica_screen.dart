import 'package:flutter/material.dart';

import '../models/ficha_clinica.dart';
import '../services/ficha_clinica_service.dart';

class FichaClinicaScreen extends StatefulWidget {
  final String pacienteUid;
  final String psicoUid;

  const FichaClinicaScreen({
    super.key,
    required this.pacienteUid,
    required this.psicoUid,
  });

  @override
  State<FichaClinicaScreen> createState() => _FichaClinicaScreenState();
}

class _FichaClinicaScreenState extends State<FichaClinicaScreen> {
  final _service = FichaClinicaService();

  final _motivoCtrl = TextEditingController();
  final _antecedentesCtrl = TextEditingController();
  final _objetivosCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarFicha();
  }

  Future<void> _cargarFicha() async {
    final ficha = await _service.obtenerFicha(
      pacienteUid: widget.pacienteUid,
      psicoUid: widget.psicoUid,
    );
    if (ficha != null) {
      _motivoCtrl.text = ficha.motivoConsulta;
      _antecedentesCtrl.text = ficha.antecedentes;
      _objetivosCtrl.text = ficha.objetivos;
    }
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);

    final ficha = FichaClinica(
      pacienteUid: widget.pacienteUid,
      psicoUid: widget.psicoUid,
      motivoConsulta: _motivoCtrl.text.trim(),
      antecedentes: _antecedentesCtrl.text.trim(),
      objetivos: _objetivosCtrl.text.trim(),
      documentosUrls: const [], // por ahora sin adjuntos
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.guardarFicha(ficha);

    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha guardada')),
    );
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _antecedentesCtrl.dispose();
    _objetivosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha clínica inicial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Motivo de consulta'),
            const SizedBox(height: 4),
            TextField(
              controller: _motivoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Antecedentes relevantes'),
            const SizedBox(height: 4),
            TextField(
              controller: _antecedentesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Objetivos terapéuticos'),
            const SizedBox(height: 4),
            TextField(
              controller: _objetivosCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar ficha'),
              onPressed: _guardando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
