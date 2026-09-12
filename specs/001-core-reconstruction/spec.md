# Spec 001 — Reconstrucción del núcleo de Nexo de Runas V2

## Objetivo
Reconstruir el flujo principal del juego en Godot 4 + GDScript con estética fiel al mockup aprobado y con arquitectura preparada para CPU y multijugador local.

## Alcance funcional
1. Pantalla principal coherente con el mockup, con acceso visible a Constructor de mazo, Batalla vs CPU y Batalla local.
2. Selección de uno de cuatro estilos/arquetipos antes de jugar.
3. Constructor de mazo visual con cartas manipulables mediante toque/arrastre.
4. Cartas con nombre, arte, coste, ataque, salud y sello.
5. Recursos válidos: Sangre, Huesos, Energía, Runas y Ninguno.
6. Tablero de batalla con mano, zonas de juego, recursos y resolución de turnos.
7. Modo CPU completamente utilizable para pruebas sin depender de conexión.
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
- Campaña narrativa completa.
- Reproducción exacta de contenido protegido que no sea necesario para prototipado privado.

## Criterios de aceptación de la primera vertical slice
- El APK abre sin pantalla gris.
- El usuario puede entrar al constructor, seleccionar/organizar cartas y volver al menú.
- El usuario puede iniciar una batalla vs CPU.
- Se renderizan cartas con estadísticas y sello.
- Se puede jugar al menos un turno completo con una regla de coste válida.
- El pipeline de GitHub Actions queda verde y entrega un APK descargable.
