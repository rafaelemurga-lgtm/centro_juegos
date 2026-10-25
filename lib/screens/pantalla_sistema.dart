
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/sistema.dart';
import '../services/caratulas_service.dart';
import '../services/favoritos_service.dart';

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
  Set<String> _favoritos = {};
  bool _cargando = true;
  bool _cargandoFavoritos = true;
  String? _error;

  Sistema get sistema => widget.sistema;

  @override
  void initState() {
    super.initState();
    _cargarRoms();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    try {
      final favoritos = await FavoritosService.obtenerFavoritos();

      if (!mounted) return;

      setState(() {
        _favoritos = favoritos
            .map((juego) => juego['ruta'])
            .whereType<String>()
            .toSet();
        _cargandoFavoritos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargandoFavoritos = false);
    }
  }

  Future<void> _cargarRoms() async {
    try {
      final directorio = Directory(sistema.carpetaRoms);

      final roms = await directorio.list().where((archivo) {
        if (archivo is! File) return false;

        final ruta = archivo.path.toLowerCase();

        return sistema.extensiones.any(
          (extension) => ruta.endsWith(extension),
        );
      }).toList();

      roms.sort(
        (a, b) => _nombreRom(a)
            .toLowerCase()
            .compareTo(_nombreRom(b).toLowerCase()),
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
        return nombre.substring(0, nombre.length - extension.length);
      }
    }

    return nombre;
  }

  Future<void> _alternarFavorito(FileSystemEntity rom) async {
    final ruta = rom.path;
    final eraFavorito = _favoritos.contains(ruta);

    setState(() {
      if (eraFavorito) {
        _favoritos.remove(ruta);
      } else {
        _favoritos.add(ruta);
      }
    });

    try {
      await FavoritosService.alternarFavorito(
        sistema: sistema.nombre,
        nombre: _nombreRom(rom),
        ruta: ruta,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (eraFavorito) {
          _favoritos.add(ruta);
        } else {
          _favoritos.remove(ruta);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el favorito:\n$e'),
        ),
      );
    }
  }

  Future<void> _lanzarRom(FileSystemEntity rom) async {
    try {
      final argumentos = <String>[];

      if (sistema.nombre == 'Xbox') {
        argumentos.addAll(['-dvd_path', rom.path]);
      } else {
        if (sistema.core != null) {
          argumentos.addAll(['-L', sistema.core!]);
        }

        argumentos.add(rom.path);
      }

      await Process.start(
        sistema.ejecutable,
        argumentos,
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar el juego:\n$e'),
        ),
      );
    }
  }

Widget _builderCaratula(FileSystemEntity rom) {
  const sinCaratula = SizedBox(
    width: 52,
    height: 68,
    child: Icon(Icons.sports_esports, size: 36),
  );

  final rutaCaratula = CaratulasService.buscarCaratula(
    nombre: _nombreRom(rom),
    sistema: sistema,
  );

  if (rutaCaratula == null) return sinCaratula;

  return Image.file(
    File(rutaCaratula),
    width: 52,
    height: 68,
    fit: BoxFit.contain,
    cacheWidth: 200, // ahorra memoria con muchos juegos
    errorBuilder: (context, error, stackTrace) => sinCaratula,
  );
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
    if (_cargando || _cargandoFavoritos) {
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
        final favorito = _favoritos.contains(rom.path);

        return Card(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _lanzarRom(rom),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        
                        _builderCaratula(rom),

                        const SizedBox(width: 12),
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
              ),
              IconButton(
                tooltip: favorito
                    ? 'Quitar de favoritos'
                    : 'Añadir a favoritos',
                onPressed: () => _alternarFavorito(rom),
                icon: Icon(
                  favorito ? Icons.star : Icons.star_border,
                  color: favorito ? Colors.amber : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
