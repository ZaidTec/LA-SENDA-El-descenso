# LA SENDA: El descenso

Videojuego 2D para Flutter y Android. Flame dibuja y actualiza el laberinto;
Flutter presenta los menús y controles. Los seis laberintos se generan de
forma procedural, incluyen enemigos patrulleros y el progreso se conserva
localmente con SharedPreferences.

## Ejecutar

Con Flutter y el Android SDK instalados, desde la raíz del proyecto:

```powershell
flutter pub get
flutter devices
flutter run
```

Para compilar un APK de lanzamiento:

```powershell
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Estructura

- `lib/main.dart`: aplicación y tema.
- `lib/models/maze_level.dart`: definición y generación de los tres laberintos.
- `lib/game/maze_game.dart`: renderizado Flame, movimiento, disparos, enemigos,
  llave, puerta y reloj.
- `lib/screens/`: menú, niveles, instrucciones, juego, récords y resultados.
- `lib/services/progress_service.dart`: niveles desbloqueados y mejores tiempos.
- `lib/widgets/direction_button.dart`: controles táctiles de movimiento continuo.
- `test/maze_level_test.dart`: comprueba que la llave y la salida sean alcanzables.

## Controles

Mantén pulsada una flecha para moverte y apuntar. Pulsa disparar para eliminar
enemigos en línea recta; los muros bloquean los disparos. Encuentra la llave y
alcanza la puerta antes de que el tiempo llegue a cero. Si un enemigo te toca,
pierdes el nivel.

## Equipo

- Integrante 1: pantallas y diseño en `lib/screens/`.
- Integrante 2: mecánicas y renderizado en `lib/game/`.
- Integrante 3: niveles, progreso, pruebas e integración.

Trabajen en ramas por tarea y revisen los cambios mediante pull requests para
reducir conflictos en los archivos compartidos.
