import 'dart:io';

import '../models/sistema.dart';

class CaratulasService {
  /// Carpeta con las carátulas (ruta absoluta, para no depender del
  /// directorio de trabajo desde el que se arranque la app).
  static const String raiz =
      r'C:\FlutterProjects\centro_juegos\assets\caratulas';

  static const _extensionesImagen = {'png', 'jpg', 'jpeg', 'webp'};

  /// carpeta del sistema → índice de sus carátulas (se lee una sola vez)
  static final Map<String, _Indice> _indices = {};

  static String? buscarCaratula({
    required String nombre,
    required Sistema sistema,
  }) {
    final carpeta = _carpetaDeSistema(sistema.nombre);
    if (carpeta == null) return null;

    var indice = _indices[carpeta];
    if (indice == null) {
      indice = _Indice.cargar('$raiz/$carpeta');
      if (indice == null) return null; // la carpeta aún no existe
      _indices[carpeta] = indice;
    }
    return indice.buscar(nombre);
  }

  /// Explica paso a paso por qué se encuentra (o no) una carátula.
  /// Uso: debugPrint(CaratulasService.diagnosticar(nombre: n, sistema: s));
  static String diagnosticar({
    required String nombre,
    required Sistema sistema,
  }) {
    final b = StringBuffer();
    b.writeln('Sistema.nombre = "${sistema.nombre}"');

    final carpeta = _carpetaDeSistema(sistema.nombre);
    b.writeln(
        'Carpeta = ${carpeta ?? "(ninguna: ese nombre no está en el mapa)"}');
    if (carpeta == null) return b.toString();

    final dir = Directory('$raiz/$carpeta');
    b.writeln('Ruta = ${dir.absolute.path}');
    b.writeln('Existe = ${dir.existsSync()}');
    b.writeln('Directorio de trabajo = ${Directory.current.path}');
    if (!dir.existsSync()) return b.toString();

    final imagenes = dir.listSync().whereType<File>().where((f) {
      final punto = f.path.lastIndexOf('.');
      return punto > 0 &&
          _extensionesImagen.contains(f.path.substring(punto + 1).toLowerCase());
    }).toList();
    b.writeln('Imágenes en la carpeta = ${imagenes.length}');
    b.writeln(
        'Ejemplos = ${imagenes.take(3).map((f) => f.path.replaceAll("\\", "/").split("/").last).join(" | ")}');

    b.writeln('Nombre buscado = "$nombre"');
    b.writeln('Clave buscada = ${_clave(_sinExtension(nombre))}');
    b.writeln(
        'Resultado = ${buscarCaratula(nombre: nombre, sistema: sistema)}');
    return b.toString();
  }

  /// Vuelve a leer las carpetas. Úsalo tras descargar carátulas nuevas
  /// con la app abierta.
  static void recargar() => _indices.clear();

  /// Nombre del sistema en tu app → nombre de la subcarpeta de carátulas,
  /// que es el de la carpeta de ROMs en el servidor.
  static String? _carpetaDeSistema(String nombre) {
    const carpetas = {
      'NES': 'NES',
      'Super Nintendo': 'SNES',
      'Sega': 'Sega',
      'Neo Geo': 'NEO-GEO Roms',
      'Nintendo 64': 'Nintendo 64',
      'Game Boy Advance': 'Nintendo GBA',
      'Nintendo DS': 'Nintendo DS',
      'Nintendo 3DS': 'Nintendo 3Ds',
      'GameCube': 'Game Cube',
      'Nintendo Wii': 'Wii',
      'MAME': 'MAME',
      'Xbox': 'Xbox',
    };

    return carpetas[nombre];
  }
}

/// Índice de una carpeta: se construye una vez y luego cada búsqueda es
/// instantánea (antes se listaba la carpeta entera por cada juego).
class _Indice {
  _Indice(this._exacto, this._porTitulo);

  /// Nombre completo (con etiquetas) normalizado → ruta
  final Map<String, String> _exacto;

  /// Título sin etiquetas normalizado → ruta (respaldo)
  final Map<String, String> _porTitulo;

  static _Indice? cargar(String ruta) {
    try {
      final directorio = Directory(ruta);
      if (!directorio.existsSync()) return null;

      final exacto = <String, String>{};
      final porTitulo = <String, String>{};

      for (final entidad in directorio.listSync()) {
        if (entidad is! File) continue;

        final rutaArchivo = entidad.path.replaceAll('\\', '/');
        final archivo = rutaArchivo.split('/').last;
        final punto = archivo.lastIndexOf('.');
        if (punto <= 0) continue;

        final extension = archivo.substring(punto + 1).toLowerCase();
        if (!CaratulasService._extensionesImagen.contains(extension)) {
          continue;
        }

        final base = _sinExtension(archivo.substring(0, punto));
        exacto.putIfAbsent(_clave(base), () => rutaArchivo);
        porTitulo.putIfAbsent(_clave(_sinEtiquetas(base)), () => rutaArchivo);
      }
      return _Indice(exacto, porTitulo);
    } catch (_) {
      return null;
    }
  }

  String? buscar(String nombre) {
    final base = _sinExtension(nombre);
    final claveExacta = _clave(base);
    if (claveExacta.isEmpty) return null;

    return _exacto[claveExacta] ?? _porTitulo[_clave(_sinEtiquetas(base))];
  }
}

/// Quita extensiones de ROM como ".zip" o ".nkit.iso" (hasta dos).
/// No toca puntos de títulos como "Super Mario Bros. 3".
String _sinExtension(String texto) {
  var s = texto;
  for (var i = 0; i < 2; i++) {
    final limpio = s.replaceAll(RegExp(r'\.[a-zA-Z0-9]{2,4}$'), '');
    if (limpio == s) break;
    s = limpio;
  }
  return s;
}

/// "Super Mario World (U) [!]" → "Super Mario World "
String _sinEtiquetas(String texto) =>
    texto.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), '');

/// Solo letras y números, en minúsculas.
String _clave(String texto) =>
    texto.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');