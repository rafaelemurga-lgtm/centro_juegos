import 'package:flutter/material.dart';

import 'configuracion_sistemas.dart';
import 'screens/pantalla_sistema.dart';

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

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  final List<Map<String, dynamic>> sistemas = const [
    {
      'nombre': 'NES',
      'icono': Icons.sports_esports,
      'sistema': sistemaNes,
    },
    {
      'nombre': 'Super Nintendo',
      'icono': Icons.sports_esports,
      'sistema': sistemaSnes,
    },
    {
      'nombre': 'Sega',
      'icono': Icons.sports_esports,
      'sistema': sistemaSega,
    },
    {
      'nombre': 'Neo Geo',
      'icono': Icons.sports_esports,
      'sistema': sistemaNeoGeo,
    },
    
    {
      'nombre': 'Nintendo 64',
      'icono': Icons.sports_esports,
      'sistema': sistemaN64,
    },
    {
      'nombre': 'Game Boy Advance',
      'icono': Icons.sports_esports,
      'sistema': sistemaGba,
    },
    {
      'nombre': 'Nintendo DS',
      'icono': Icons.sports_esports,
      'sistema': sistemaNintendoDs,
    },
    {
      'nombre': 'Nintendo 3DS', 
      'icono': Icons.sports_esports, 
      'sistema': sistemaNintendo3Ds},
    {
      'nombre': 'GameCube',
      'icono': Icons.sports_esports,
      'sistema': sistemaGameCube,
    },
    {
      'nombre': 'Nintendo Wii',
      'icono': Icons.sports_esports,
      'sistema': sistemaNintendoWii,
    },
    {
      'nombre': 'MAME',
      'icono': Icons.sports_esports,
      'sistema': sistemaMame,
    },
    {
      'nombre': 'Xbox',
      'icono': Icons.sports_esports,
      'sistema': sistemaXbox,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Centro de Juegos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisExtent: 180,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: sistemas.length,
          itemBuilder: (context, index) {
            final sistema = sistemas[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  final configuracion = sistema['sistema'];

                  if (configuracion != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaSistema(
                          sistema: configuracion,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${sistema['nombre']} todavía no está configurado.',
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sistema['icono'] as IconData,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sistema['nombre'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}