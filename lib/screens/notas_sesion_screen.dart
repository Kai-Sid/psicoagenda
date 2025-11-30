import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../models/nota_privada.dart';
import '../services/notas_service.dart';

class NotasSesionScreen extends StatefulWidget {
  final Sesion sesion;

  const NotasSesionScreen({super.key, required this.sesion});

  @override
  State<NotasSesionScreen> createState() => _NotasSesionScreenState();
}

class _NotasSesionScreenState extends State<NotasSesionScreen> {
  final _notasService = NotasService();
  final _controller = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _guardarNota() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    try {
      await _notasService.agregarNota(
        sesionId: widget.sesion.id,
        psicoUid: widget.sesion.psicoUid,
        pacienteUid: widget.sesion.pacienteUid,
        contenido: texto,
      );
      _controller.clear();
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sesion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas privadas de sesión'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Sesión del '
              '${s.fecha.day}/${s.fecha.month}/${s.fecha.year} '
              '${s.fecha.hour.toString().padLeft(2, '0')}:'
              '${s.fecha.minute.toString().padLeft(2, '0')} · '
              '${s.modalidad} · Estado: ${s.estado}',
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<NotaPrivada>>(
              stream: _notasService.notasDeSesion(s.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notas = snapshot.data ?? [];
                if (notas.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay notas para esta sesión'),
                  );
                }
                return ListView.builder(
                  itemCount: notas.length,
                  itemBuilder: (context, index) {
                    final n = notas[index];
                    final fecha = n.createdAt;
                    final fechaTxt =
                        '${fecha.day}/${fecha.month}/${fecha.year} '
                        '${fecha.hour.toString().padLeft(2, '0')}:'
                        '${fecha.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text(n.contenido),
                      subtitle: Text('Creada: $fechaTxt'),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una nota privada...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _enviando
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _enviando ? null : _guardarNota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
