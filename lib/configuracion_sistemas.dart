import 'models/sistema.dart';

const sistemaNes = Sistema(
  nombre: 'NES',
  plataforma: 'Nintendo Entertainment System',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\mesen_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\NES',
  extensiones: [
    '.zip',
    '.nes',
  ],
);

const sistemaSnes = Sistema(
  nombre: 'Super Nintendo',
  plataforma: 'Super Nintendo Entertainment System',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\snes9x2010_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\SNES',
  extensiones: [
    '.zip',
  ],
);

const sistemaSega = Sistema(
  nombre: 'Sega',
  plataforma: 'Sega Genesis / Mega Drive',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\blastem_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Sega',
  extensiones: [
    '.zip',
  ],
);

const sistemaNeoGeo = Sistema(
  nombre: 'Neo Geo',
  plataforma: 'Neo Geo / Arcade',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\fbneo_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\NEO-GEO Roms',
  extensiones: [
    '.zip',
  ],
);

const sistemaN64 = Sistema(
  nombre: 'Nintendo 64',
  plataforma: 'Nintendo 64',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\mupen64plus_next_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Nintendo 64',
  extensiones: [
    '.zip',
  ],
);

const sistemaGba = Sistema(
  nombre: 'Game Boy Advance',
  plataforma: 'Game Boy Advance',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\mgba_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Nintendo GBA',
  extensiones: [
    '.zip',
  ],
);