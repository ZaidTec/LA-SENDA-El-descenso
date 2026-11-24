# LA SENDA: El descenso

Videojuego 2D para Flutter y Android. Flame dibuja y actualiza el laberinto;
Flutter presenta las pantallas, menús y controles. Las expediciones incluyen
enemigos patrulleros y el progreso se conserva localmente con SharedPreferences.

## Flujo del juego

- **Jugar** presenta la introducción narrativa la primera vez y después abre el
  campamento base.
- La portada conserva la ilustración pixel art original y anima las llamas,
  las brasas, los destellos de la llave y el reflejo de las antorchas. Los
  botones reaccionan al cursor y al toque.
- Desde el campamento se accede al mapa de expediciones, el puesto del
  arqueólogo, el diario de campo (récords) y las opciones.
- El mapa permite iniciar los niveles desbloqueados. En la partida se puede
  pausar, continuar, reiniciar o volver al campamento.
- Al ganar se guarda el tiempo y se acredita una recompensa única por nivel;
  desde el resumen se puede visitar la tienda. Al perder se puede reintentar o
  regresar al campamento.
- Los objetos de la tienda son cosméticos y cambian los colores del explorador;
  no alteran la dificultad ni las reglas de la partida.
- Las opciones guardan los volúmenes y permiten elegir cruceta táctil o
  joystick. Los niveles de volumen quedan guardados para integrar audio en una
  actualización futura.
- Las pantallas usan una paleta de caverna, piedra y madera con acentos de
  antorcha. La tipografía y los controles son cuadrados para mantener el estilo
  pixel art de la portada; el mapa usa suelo terroso y muros de piedra tallados.

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

- `lib/main.dart`: punto de entrada, tema y rutas iniciales.
- `lib/screens/`: interfaz Flutter, con `main_menu_screen.dart`,
  `game_screen.dart`, `shop_screen.dart` y el resto de pantallas del flujo.
- `lib/game/la_senda_game.dart`: clase Flame que coordina la partida, el
  renderizado, movimiento, enemigos, disparos, llave, puerta y reloj.
- `lib/game/components/`: estado y lógica del jugador, enemigos y proyectiles.
- `lib/game/levels/level_manager.dart`: definición, catálogo y generación
  procedural de los seis laberintos actuales.
- `lib/game/overlays/`: máscara de iluminación y HUD.
- `lib/utils/constants.dart`: constantes globales y colores.
- `lib/utils/progress_service.dart`: progreso, récords, recompensas,
  preferencias e inventario.
- `lib/screens/widgets/direction_button.dart`: cruceta táctil.
- `assets/images/`: imágenes del juego; incluye la portada pixel art.
- `assets/tiles/`: espacio para recursos gráficos de tiles y mapas.
- `test/`: pruebas del generador, el juego y las pantallas.

Esta organización conserva las mecánicas actuales: los mapas siguen generándose
en Dart (no se cargan mapas Tiled `.tmx`) y el ataque sigue siendo un disparo
lineal. La migración a Tiled o a un boomerang que regrese sería un cambio de
jugabilidad separado.

## Controles

Usa la cruceta para moverte y apuntar o arrastra el joystick hacia una
dirección. Pulsa disparar para eliminar enemigos en línea recta; los muros
bloquean los disparos. Encuentra la llave y alcanza la puerta antes de que el
tiempo llegue a cero. Si un enemigo te toca, pierdes el nivel.

## Equipo

- Integrante 1: pantallas y diseño en `lib/screens/`.
- Integrante 2: mecánicas y renderizado en `lib/game/`.
- Integrante 3: niveles, progreso, pruebas e integración.

Trabajen en ramas por tarea y revisen los cambios mediante pull requests para
reducir conflictos en los archivos compartidos.
