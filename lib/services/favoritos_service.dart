
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  static const String _clave = 'centro_juegos_favoritos';

  static Future<List<Map<String, String>>> obtenerFavoritos() async {
    final preferencias = await SharedPreferences.getInstance();
    final contenido = preferencias.getString(_clave);

    if (contenido == null || contenido.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> datos = jsonDecode(contenido) as List<dynamic>;

      return datos
          .whereType<Map<String, dynamic>>()
          .map(
            (dato) => dato.map(
              (clave, valor) => MapEntry(clave, valor.toString()),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> esFavorito(String ruta) async {
    final favoritos = await obtenerFavoritos();
    return favoritos.any((juego) => juego['ruta'] == ruta);
  }

  static Future<void> alternarFavorito({
    required String sistema,
    required String nombre,
    required String ruta,
  }) async {
    final preferencias = await SharedPreferences.getInstance();
    final favoritos = await obtenerFavoritos();

    final existe = favoritos.any((juego) => juego['ruta'] == ruta);

    if (existe) {
      favoritos.removeWhere((juego) => juego['ruta'] == ruta);
    } else {
      favoritos.add({
        'sistema': sistema,
        'nombre': nombre,
        'ruta': ruta,
      });
    }

    await preferencias.setString(_clave, jsonEncode(favoritos));
  }
}
