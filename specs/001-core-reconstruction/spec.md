# Spec 001 — Reconstrucción del núcleo de Nexo de Runas V2

## Objetivo
Reconstruir el flujo principal del juego en Godot 4 + GDScript con estética fiel al mockup aprobado y con arquitectura preparada para CPU y multijugador local.

## Alcance funcional
1. Pantalla principal coherente con el mockup, con acceso visible a Constructor de mazo, Campaña Acto 1 y Batalla local.
2. Selección de uno de cuatro estilos/arquetipos antes de jugar.
3. Constructor de mazo visual con cartas manipulables mediante toque/arrastre.
4. Cartas con nombre, arte, coste, ataque, salud y sello.
5. Recursos válidos: Sangre, Huesos, Energía, Runas y Ninguno.
6. Tablero de batalla con mano, zonas de juego, recursos y resolución de turnos.
7. Campaña Acto 1 offline con CPU como controlador de enemigos, según el alcance ampliado de abajo.
8. Modo local Wi‑Fi como fase posterior al combate estable.

## Requisitos visuales
- Pixel-art y composición inspirada en el Acto 2, sin convertir la interfaz en un TCG moderno genérico.
- El constructor de mazo debe compartir la misma dirección visual que batalla y menú.
- Ataque y salud visibles como números.
- El sello debe representarse visualmente en la carta.
- No se usa overlay por hover/deslizamiento para información ya disponible mediante toque.
- Las cartas deben ocupar una proporción útil de pantalla en Android y ser cómodas de tocar.

## Requisitos técnicos
- Godot 4.x + GDScript.
- Resolución base 1280×720 horizontal y escalado mediante `canvas_items`.
- Estado de juego desacoplado de UI.
- Reglas deterministas reutilizables por CPU y red local.
- Exportación Android automática por GitHub Actions.
- Validación de estructura antes de exportar.

## Fuera de alcance inmediato
- Matchmaking por Internet.
- Backend permanente.
- Monetización.
- Reproducción exacta de contenido protegido que no sea necesario para prototipado privado.

## Criterios de aceptación de la primera vertical slice
- El APK abre sin pantalla gris.
- El usuario puede entrar al constructor, seleccionar/organizar cartas y volver al menú.
- El usuario puede iniciar una batalla contra CPU dentro de la campaña.
- Se renderizan cartas con estadísticas y sello.
- Se puede jugar al menos un turno completo con una regla de coste válida.
- El pipeline de GitHub Actions queda verde y entrega un APK descargable.

## Cambio de alcance aprobado — Campaña Acto 1
El usuario solicita reemplazar el acceso «Batalla vs CPU» por una campaña basada en el Acto 1 de Inscryption, incluyendo mapa/minimapa de rutas, encuentros y minijuegos, puzzles, elección de cartas y jefes. No es un cambio de etiqueta ni un combate aislado.
- Mantener Constructor de mazo y Batalla local; no borrar esas rutas.
- La CPU continúa como controlador de enemigos offline dentro de la campaña.
- Mantener provisionalmente la dirección pixel-art aprobada; el cambio solicitado de contenido no implica por sí solo una conversión a 3D.
- El mazo de campaña progresa dentro de cada expedición y se guarda separado del mazo libre/local. Las reglas de campaña no heredan automáticamente el límite de 20 ni la prohibición de duplicados del prototipo.
- Mapa ramificado con conexiones visibles, posición, rutas disponibles y nodos resueltos. No permitir saltar a nodos inaccesibles.
- Elección de cartas, encuentros de mejora/intercambio/sacrificio y minijuegos con consecuencias persistentes. Recompensas reclamables una sola vez.
- Combate offline completo: mano, robo, sacrificios, recursos, sellos, daño, victoria y derrota; jamás resolverlo mediante un botón «ganar».
- Jefes con patrones y fases propias, recompensas y avance de región; no enemigos normales renombrados.
- Espacio de exploración/puzzles con pistas, soluciones y desbloqueos persistentes, accesible con controles táctiles.
- Nueva partida, continuar, derrota y reinicio; guardado versionado al resolver eventos y recuperación segura sin duplicar recompensas.
- Inventariar contenido y reglas del Acto 1 contra referencias verificadas antes de declarar fidelidad completa. Los adjuntos aún no se han podido inspeccionar en esta sesión.
- No dar por terminada la campaña hasta poder recorrerla de inicio a final en Android, incluidos puzzles y jefes.

### Primera entrega verificable de campaña
Nueva partida → mapa con bifurcación → elección de carta → batalla real → recompensa → regreso al mapa → guardar y continuar. Es una primera entrega parcial, no «todo el Acto 1».
