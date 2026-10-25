import 'dart:io';

import 'package:flutter/material.dart';

import 'configuracion_sistemas.dart';
import 'models/sistema.dart';
import 'screens/pantalla_sistema.dart';
import 'services/buscador_juegos_service.dart';
import 'services/caratulas_service.dart';
import 'services/favoritos_service.dart';

void main() {
  runApp(const CentroJuegosApp());
}

class CentroJuegosApp extends StatelessWidget {
  const CentroJuegosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro de Juegos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<Map<String, String>> _favoritos = [];
  bool _cargandoFavoritos = true;
  List<JuegoEncontrado> _todosLosJuegos = [];
  bool _cargandoJuegos = true;
  String _consulta = '';

  final TextEditingController _busquedaController = TextEditingController();
  final ScrollController _consolasController = ScrollController();

  final List<Map<String, dynamic>> sistemas = const [
    {'nombre': 'NES', 'imagen': 'nes.png', 'sistema': sistemaNes},
    {'nombre': 'Super Nintendo', 'imagen': 'snes.png', 'sistema': sistemaSnes},
    {'nombre': 'Sega', 'imagen': 'sega.png', 'sistema': sistemaSega},
    {'nombre': 'Neo Geo', 'imagen': 'neo_geo.png', 'sistema': sistemaNeoGeo},
    {
      'nombre': 'Nintendo 64',
      'imagen': 'nintendo_64.png',
      'sistema': sistemaN64
    },
    {
      'nombre': 'Game Boy Advance',
      'imagen': 'game_boy_advance.png',
      'sistema': sistemaGba
    },
    {
      'nombre': 'Nintendo DS',
      'imagen': 'nintendo_ds.png',
      'sistema': sistemaNintendoDs
    },
    {
      'nombre': 'Nintendo 3DS',
      'imagen': 'nintendo_3ds.png',
      'sistema': sistemaNintendo3Ds
    },
    {'nombre': 'GameCube', 'imagen': 'gamecube.png', 'sistema': sistemaGameCube},
    {
      'nombre': 'Nintendo Wii',
      'imagen': 'wii.png',
      'sistema': sistemaNintendoWii
    },
    {'nombre': 'MAME', 'imagen': 'mame.png', 'sistema': sistemaMame},
    {'nombre': 'Xbox', 'imagen': 'xbox.png', 'sistema': sistemaXbox},
  ];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
    _cargarTodosLosJuegos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _consolasController.dispose();
    super.dispose();
  }

  Future<void> _cargarTodosLosJuegos() async {
    try {
      final configuraciones = sistemas
          .map((elemento) => elemento['sistema'])
          .whereType<Sistema>()
          .toList();

      final juegos = await BuscadorJuegosService.cargarJuegos(
        configuraciones,
      );

      if (!mounted) return;

      setState(() {
        _todosLosJuegos = juegos;
        _cargandoJuegos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargandoJuegos = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los juegos: $e')),
      );
    }
  }

  Future<void> _cargarFavoritos() async {
    try {
      final favoritos = await FavoritosService.obtenerFavoritos();

      if (!mounted) return;

      setState(() {
        _favoritos = favoritos;
        _cargandoFavoritos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoFavoritos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los favoritos: $e')),
      );
    }
  }

  Sistema? _buscarSistema(String? nombre) {
    for (final elemento in sistemas) {
      if (elemento['nombre'] == nombre) {
        return elemento['sistema'] as Sistema?;
      }
    }
    return null;
  }

  Future<void> _abrirSistema(Sistema sistema) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaSistema(sistema: sistema),
      ),
    );

    await _cargarFavoritos();
  }

  Future<void> _lanzarFavorito(Map<String, String> favorito) async {
    final sistema = _buscarSistema(favorito['sistema']);
    final ruta = favorito['ruta'];

    if (sistema == null || ruta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo identificar el sistema de este favorito.'),
        ),
      );
      return;
    }

    if (!await File(ruta).exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se encontró el archivo del juego:\n${favorito['nombre'] ?? ruta}',
          ),
        ),
      );
      return;
    }

    try {
      final argumentos = <String>[];

      if (sistema.nombre == 'Xbox') {
        argumentos.addAll(['-dvd_path', ruta]);
      } else {
        if (sistema.core != null) {
          argumentos.addAll(['-L', sistema.core!]);
        }
        argumentos.add(ruta);
      }

      await Process.start(
        sistema.ejecutable,
        argumentos,
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el juego:\n$e')),
      );
    }
  }

  List<JuegoEncontrado> get _juegosFiltrados {
    final consulta = _consulta.trim().toLowerCase();
    if (consulta.isEmpty) return [];

    return _todosLosJuegos.where((juego) {
      return juego.nombre.toLowerCase().contains(consulta) ||
          juego.sistema.nombre.toLowerCase().contains(consulta);
    }).toList();
  }

  Future<void> _lanzarJuegoEncontrado(JuegoEncontrado juego) async {
    if (!await File(juego.ruta).exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el juego: ${juego.nombre}')),
      );
      return;
    }

    try {
      final argumentos = <String>[];

      if (juego.sistema.nombre == 'Xbox') {
        argumentos.addAll(['-dvd_path', juego.ruta]);
      } else {
        if (juego.sistema.core != null) {
          argumentos.addAll(['-L', juego.sistema.core!]);
        }
        argumentos.add(juego.ruta);
      }

      await Process.start(
        juego.sistema.ejecutable,
        argumentos,
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el juego: $e')),
      );
    }
  }

  Future<void> _alternarFavoritoEncontrado(JuegoEncontrado juego) async {
    final ruta = juego.ruta;
    final eraFavorito = _favoritos.any((favorito) => favorito['ruta'] == ruta);

    setState(() {
      if (eraFavorito) {
        _favoritos.removeWhere((favorito) => favorito['ruta'] == ruta);
      } else {
        _favoritos.add({
          'sistema': juego.sistema.nombre,
          'nombre': juego.nombre,
          'ruta': ruta,
        });
      }
    });

    try {
      await FavoritosService.alternarFavorito(
        sistema: juego.sistema.nombre,
        nombre: juego.nombre,
        ruta: ruta,
      );
    } catch (e) {
      await _cargarFavoritos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el favorito: $e')),
      );
    }
  }

  Future<void> _quitarFavorito(Map<String, String> favorito) async {
    final ruta = favorito['ruta'];
    if (ruta == null) return;

    setState(() {
      _favoritos.removeWhere((juego) => juego['ruta'] == ruta);
    });

    try {
      await FavoritosService.alternarFavorito(
        sistema: favorito['sistema'] ?? '',
        nombre: favorito['nombre'] ?? '',
        ruta: ruta,
      );
    } catch (e) {
      await _cargarFavoritos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo quitar el favorito:\n$e')),
      );
    }
  }

  // Las carátulas están en el disco, por eso se usa Image.file
  // (Image.asset solo sirve para imágenes empaquetadas en la app).
  Widget _construirCaratulaFavorito(Map<String, String> favorito) {
    const icono = Icon(Icons.sports_esports, size: 36);

    final sistema = _buscarSistema(favorito['sistema']);
    if (sistema == null) return icono;

    final ruta = CaratulasService.buscarCaratula(
      nombre: favorito['nombre'] ?? '',
      sistema: sistema,
    );
    if (ruta == null) return icono;

    return Image.file(
      File(ruta),
      width: 76,
      height: 100,
      fit: BoxFit.contain,
      cacheWidth: 300,
      errorBuilder: (_, _, _) => icono,
    );
  }

  Widget _construirCaratulaBusqueda(JuegoEncontrado juego) {
    const icono = SizedBox(
      width: 48,
      height: 64,
      child: Icon(Icons.sports_esports),
    );

    final ruta = CaratulasService.buscarCaratula(
      nombre: juego.nombre,
      sistema: juego.sistema,
    );
    if (ruta == null) return icono;

    return Image.file(
      File(ruta),
      width: 48,
      height: 64,
      fit: BoxFit.contain,
      cacheWidth: 200,
      errorBuilder: (_, _, _) => icono,
    );
  }

  Widget _construirImagenConsola(String archivo) {
    return Image.asset(
      'assets/consolas/$archivo',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.sports_esports, size: 64);
      },
    );
  }

  Widget _construirTarjetaConsola(Map<String, dynamic> elemento) {
    final sistema = elemento['sistema'] as Sistema;

    return SizedBox(
      width: 150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirSistema(sistema),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: _construirImagenConsola(
                    elemento['imagen'] as String,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: Center(
                    child: Text(
                      elemento['nombre'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirTarjetaFavorito(Map<String, String> favorito) {
    final nombre = favorito['nombre'] ?? 'Juego';
    final nombreSistema = favorito['sistema'] ?? 'Sistema';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _lanzarFavorito(favorito),
        child: Row(
          children: [
            Container(
              width: 86,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: _construirCaratulaFavorito(favorito),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nombreSistema,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Quitar de favoritos',
              onPressed: () => _quitarFavorito(favorito),
              icon: const Icon(Icons.star, color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Centro de Juegos'),
        centerTitle: true,
      ),
      body: _cargandoFavoritos
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: TextField(
                      controller: _busquedaController,
                      onChanged: (valor) {
                        setState(() => _consulta = valor.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar juegos en todos los sistemas',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _consulta.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpiar búsqueda',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _busquedaController.clear();
                                  setState(() => _consulta = '');
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_consulta.isNotEmpty) ...[
                  if (_cargandoJuegos)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_juegosFiltrados.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No se encontraron juegos.'),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Text('Resultados: ${_juegosFiltrados.length}'),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final juego = _juegosFiltrados[index];
                            final esFavorito = _favoritos.any(
                              (favorito) => favorito['ruta'] == juego.ruta,
                            );

                            return Card(
                              child: ListTile(
                                leading: _construirCaratulaBusqueda(juego),
                                title: Text(
                                  juego.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(juego.sistema.nombre),
                                onTap: () => _lanzarJuegoEncontrado(juego),
                                trailing: IconButton(
                                  tooltip: esFavorito
                                      ? 'Quitar de favoritos'
                                      : 'Añadir a favoritos',
                                  onPressed: () =>
                                      _alternarFavoritoEncontrado(juego),
                                  icon: Icon(
                                    esFavorito ? Icons.star : Icons.star_border,
                                    color: esFavorito ? Colors.amber : null,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _juegosFiltrados.length,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
                      child: Text(
                        'Consolas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: Scrollbar(
                        controller: _consolasController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _consolasController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: sistemas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              _construirTarjetaConsola(sistemas[index]),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Mis favoritos (${_favoritos.length})',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_favoritos.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
                        child: Text(
                          'Todavía no tienes favoritos. Entra en un sistema '
                          'y pulsa la estrella de los juegos que quieras guardar.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          mainAxisExtent: 130,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _construirTarjetaFavorito(_favoritos[index]),
                          childCount: _favoritos.length,
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}