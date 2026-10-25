import 'dart:io';

import 'package:flutter/material.dart';

import '../models/sistema.dart';
import '../services/caratulas_service.dart'; // ajusta la ruta a donde lo tengas

/// Muestra la carátula de un juego, o un icono si no existe.
///
/// Uso:
///   Caratula(nombre: juego.nombre, sistema: juego.sistema)
class Caratula extends StatelessWidget {
  const Caratula({
    super.key,
    required this.nombre,
    required this.sistema,
    this.fit = BoxFit.cover,
  });

  final String nombre;
  final Sistema sistema;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ruta = CaratulasService.buscarCaratula(
      nombre: nombre,
      sistema: sistema,
    );

    if (ruta == null) return const _SinCaratula();

    return Image.file(
      File(ruta),
      fit: fit,
      cacheWidth: 400, // ahorra memoria en cuadrículas grandes
      errorBuilder: (_, _, _) => const _SinCaratula(),
    );
  }
}

class _SinCaratula extends StatelessWidget {
  const _SinCaratula();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.videogame_asset, size: 48)),
    );
  }
}