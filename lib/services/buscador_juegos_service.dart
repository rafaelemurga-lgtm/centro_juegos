import 'dart:io';

import '../models/sistema.dart';

class JuegoEncontrado {
  final String nombre;
  final Sistema sistema;
  final String ruta;

  const JuegoEncontrado({
    required this.nombre,
    required this.sistema,
    required this.ruta,
  });
}

class BuscadorJuegosService {
  static Future<List<JuegoEncontrado>> cargarJuegos(
    List<Sistema> sistemas,
  ) async {
    final juegos = <JuegoEncontrado>[];

    for (final sistema in sistemas) {
      try {
        final directorio = Directory(sistema.carpetaRoms);

        await for (final archivo in directorio.list()) {
          if (archivo is! File) continue;

          final nombreArchivo = archivo.path
              .split(Platform.pathSeparator)
              .last;
          final nombreMinusculas = nombreArchivo.toLowerCase();

          final extension = sistema.extensiones.where(
            (ext) => nombreMinusculas.endsWith(ext.toLowerCase()),
          ).firstOrNull;

          if (extension == null) continue;

          juegos.add(
            JuegoEncontrado(
              nombre: nombreArchivo.substring(
                0,
                nombreArchivo.length - extension.length,
              ),
              sistema: sistema,
              ruta: archivo.path,
            ),
          );
        }
      } catch (_) {
        // Una carpeta inaccesible no debe detener la búsqueda.
        continue;
      }
    }

    juegos.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(
        b.nombre.toLowerCase(),
      ),
    );

    return juegos;
  }
}
