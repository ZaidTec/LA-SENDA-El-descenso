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

- `lib/main.dart`: aplicación y tema.
- `lib/models/maze_level.dart`: definición y generación de los tres laberintos.
- `lib/game/maze_game.dart`: renderizado Flame, movimiento, disparos, enemigos,
  llave, puerta y reloj.
- `lib/screens/`: portada, introducción, campamento, opciones, tienda,
  expediciones, instrucciones, juego, récords y resultados.
- `assets/images/la_senda_cover.png`: imagen pixel art usada directamente en la portada.
- `lib/screens/menu_screen.dart`: muestra la portada y ubica los controles
  táctiles encima de Jugar, Opciones y Salir; también anima el fuego y las
  chispas sin modificar la ilustración base.
- `lib/services/progress_service.dart`: progreso, récords, recompensas,
  preferencias e inventario.
- `lib/widgets/direction_button.dart`: cruceta táctil para el movimiento.
- `test/maze_level_test.dart`: comprueba que la llave y la salida sean alcanzables.

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
