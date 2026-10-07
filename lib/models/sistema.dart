class Sistema {
  final String nombre;
  final String plataforma;
  final String ejecutable;
  final String? core;
  final String carpetaRoms;
  final List<String> extensiones;

  const Sistema({
    required this.nombre,
    required this.plataforma,
    required this.ejecutable,
    this.core,
    required this.carpetaRoms,
    required this.extensiones,
  });
}