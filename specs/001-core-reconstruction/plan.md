# Plan 001 — Reconstrucción Acto 1

## Arquitectura objetivo

### 1. Dominio (`scripts/domain/`)
- `card_catalog.gd`: cartas activas del Acto 1, coste de Sangre/Huesos, estadísticas y sellos.
- `battle_state.gd`: mano, mazo principal, reserva de ardillas, cuatro carriles, sacrificios, Huesos, balanza y resolución.
- `campaign_state.gd`: semilla, región, nodo actual, rutas, mazo de expedición, inventario y progreso.
- `campaign_save.gd`: guardado versionado y recuperación segura.
- Reglas deterministas y serializables; la UI no decide resultados.

### 2. Presentación
- Fase de transición: Controls 2D oscuros únicamente para mantener el juego exportable.
- Objetivo: escena 2.5D/3D de cabaña y mesa con iluminación cálida, madera, sombras y profundidad.
- Cartas como objetos físicos reutilizables en mano, mesa, elección y eventos.
- Mapa como objeto físico/papel, no como árbol de botones estilo menú.

### 3. CPU
- El oponente usa el mismo motor de reglas.
- Los encuentros definen cola/patrones de cartas propios.
- Jefes tendrán estados/fases, no serán enemigos normales renombrados.

### 4. Modos aplazados
- Multijugador local y cualquier estética/sistema del Acto 2 se posponen hasta completar la experiencia principal del Acto 1.

## Secuencia de implementación
1. Bloquear dirección Acto 1 en Constitución/Spec/Tasks/AGENTS.
2. Retirar del menú principal Constructor de mazo por facciones y Batalla local.
3. Sustituir catálogo activo por cartas orgánicas de Sangre/Huesos/Ninguno.
4. Implementar reserva de ardillas, robo alternativo y sacrificios explícitos.
5. Rehacer la primera expedición: mapa → elección → combate → recompensa → fogata → guardado.
6. Rehacer presentación visual en dirección terror/cabaña; eliminar restos de Acto 2.
7. Añadir objetos, tótems/talladores, sacrificios de sellos, trampas y encuentros.
8. Implementar jefes y regiones completas.
9. Construir exploración 3D de la cabaña y puzzles persistentes.
10. Pulido audiovisual, feedback táctil, pruebas en Android y convergencia final.

## Principios de implementación
- Una unidad jugable y exportable por iteración.
- La fidelidad de sensación pesa más que la cantidad de contenido.
- No introducir recursos o UI del Acto 2 por conveniencia técnica.
- Sangre y sacrificios deben sentirse como una acción explícita del jugador, nunca como un descuento automático oculto.
- La UI temporal no define la arquitectura final.

## Estrategia de verificación
- `tools/validate_project.py` valida estructura crítica.
- GitHub Actions importa/exporta con Godot 4.3 antes de entregar APK.
- En Android se comprueba: orientación, tamaño táctil, claridad de sacrificios, robo, juego de carta y navegación.
- Cada entrega se contrasta contra `spec.md` y `tasks.md`.

## Puertas de convergencia del Acto 1
1. Cero elementos visibles de las cuatro facciones del Acto 2 en el flujo principal.
2. Combate con Sangre, Huesos, ardillas y sacrificios realmente jugables.
3. Mapa/eventos que modifican el mazo de expedición sin constructor externo.
4. Guardado/continuar y recompensas únicas.
5. Primer jefe funcional.
6. Mesa/cabaña con dirección 2.5D/3D de terror.
7. Exploración y puzzles de cabaña.
8. Recorrido completo del Acto 1 antes de retomar cualquier modo secundario.
