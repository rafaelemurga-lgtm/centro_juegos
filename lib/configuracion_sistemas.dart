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

const sistemaNintendoDs = Sistema(
  nombre: 'Nintendo DS',
  plataforma: 'Nintendo DS',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\melonds_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Nintendo DS',
  extensiones: [
    '.zip',
    '.7z',
  ],
);

const sistemaNintendo3Ds = Sistema(
  nombre: 'Nintendo 3DS',
  plataforma: 'Nintendo 3DS',
  ejecutable: r'C:\Program Files\Azahar\azahar.exe',
  core: '',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Nintendo 3Ds',
  extensiones: ['.3ds'],
);

const sistemaGameCube = Sistema(
  nombre: 'GameCube',
  plataforma: 'Nintendo GameCube',
  ejecutable: r'C:\Users\Rafael Eduardo\Games\dolphin-2512-x64\Dolphin-x64\Dolphin.exe',
  core: null,
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Game Cube',
  extensiones: ['.iso', '.rvz', '.gcz', '.wbfs'],
);

const sistemaNintendoWii = Sistema(
  nombre: 'Nintendo Wii',
  plataforma: 'Nintendo Wii',
  ejecutable: r'C:\Users\Rafael Eduardo\Games\dolphin-2512-x64\Dolphin-x64\Dolphin.exe',
  core: null,
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Wii',
  extensiones: ['.iso', '.rvz', '.wbfs', '.gcz'],
);

const sistemaMame = Sistema(
  nombre: 'MAME',
  plataforma: 'Arcade / FinalBurn Neo',
  ejecutable: r'C:\RetroArch-Win64\retroarch.exe',
  core: r'C:\RetroArch-Win64\cores\fbneo_libretro.dll',
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\MAME',
  extensiones: ['.zip'],
);

const sistemaXbox = Sistema(
  nombre: 'Xbox',
  plataforma: 'Xbox',
  ejecutable:
      r'C:\Users\Rafael Eduardo\Games\xemu-0.8.133-windows-x86_64\xemu.exe',
  core: null,
  carpetaRoms: r'\\RAFITASERVER\Tres\ROMs\Xbox',
  extensiones: ['.iso'],
);
