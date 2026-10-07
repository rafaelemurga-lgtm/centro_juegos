import 'dart:io';

import 'package:flutter/material.dart';

import '../models/sistema.dart';

class PantallaSistema extends StatefulWidget {
  final Sistema sistema;

  const PantallaSistema({
    super.key,
    required this.sistema,
  });

  @override
  State<PantallaSistema> createState() => _PantallaSistemaState();
}

class _PantallaSistemaState extends State<PantallaSistema> {
  List<FileSystemEntity> _roms = [];
  bool _cargando = true;
  String? _error;

  Sistema get sistema => widget.sistema;

  @override
  void initState() {
    super.initState();
    _cargarRoms();
  }

  Future<void> _cargarRoms() async {
    try {
      final directorio = Directory(sistema.carpetaRoms);

      final roms = await directorio
          .list()
          .where((archivo) {
            if (archivo is! File) {
              return false;
            }

            final ruta = archivo.path.toLowerCase();

            return sistema.extensiones.any(
              (extension) => ruta.endsWith(extension),
            );
          })
          .toList();

      roms.sort(
        (a, b) => _nombreRom(a).toLowerCase().compareTo(
              _nombreRom(b).toLowerCase(),
            ),
      );

      if (!mounted) return;

      setState(() {
        _roms = roms;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  String _nombreRom(FileSystemEntity archivo) {
    final nombre = archivo.path.split(Platform.pathSeparator).last;

    for (final extension in sistema.extensiones) {
      if (nombre.toLowerCase().endsWith(extension)) {
        return nombre.substring(
          0,
          nombre.length - extension.length,
        );
      }
    }

    return nombre;
  }

  Future<void> _lanzarRom(FileSystemEntity rom) async {
    try {
      final argumentos = <String>[];

      if (sistema.core != null) {
        argumentos.addAll([
          '-L',
          sistema.core!,
        ]);
      }

      argumentos.add(rom.path);

      await Process.start(
        sistema.ejecutable,
        argumentos,
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo iniciar el juego:\n$e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎮 ${sistema.nombre}'),
      ),
      body: _construirContenido(),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No se pudieron cargar los juegos:\n\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_roms.isEmpty) {
      return const Center(
        child: Text('No se encontraron juegos.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 100,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _roms.length,
      itemBuilder: (context, index) {
        final rom = _roms[index];

        return Card(
          child: InkWell(
            onTap: () => _lanzarRom(rom),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_esports,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _nombreRom(rom),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}