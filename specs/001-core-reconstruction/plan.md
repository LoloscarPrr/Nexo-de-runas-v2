# Plan 001 — Arquitectura y orden de implementación

## Arquitectura propuesta

### 1. Dominio (`scripts/domain/`)
- `card_data.gd`: definición de carta, coste, estadísticas y sellos.
- `deck_state.gd`: mazo, mano, descarte/reserva y validaciones.
- `battle_state.gd`: turnos, recursos, tablero y resolución.
- `rules_engine.gd`: acciones válidas, costes, sacrificios y efectos.

### 2. Presentación (`scenes/ui/`, `scripts/ui/`)
- `main_menu`: navegación principal.
- `deck_builder`: organización visual del mazo.
- `card_view`: componente reutilizable para carta.
- `battle`: tablero y HUD.
- Los nodos visuales observan estado; no contienen reglas irreemplazables.

### 3. Jugadores (`scripts/players/`)
- `human_controller.gd`: convierte input táctil en acciones.
- `cpu_controller.gd`: elige acciones legales sobre el mismo motor de reglas.

### 4. Red local (`scripts/network/`)
- Se implementa después de estabilizar CPU.
- Transporta acciones/estado serializable, no referencias directas a nodos de UI.

## Secuencia
1. Guardrails, specs y CI.
2. Shell visual del menú y navegación.
3. Modelo de cartas y componente `CardView`.
4. Constructor de mazo.
5. Motor mínimo de batalla.
6. CPU.
7. Recursos/sellos adicionales.
8. Wi‑Fi local.
9. Pulido visual, sonido y pruebas de regresión.

## Principios de implementación
- Cambios pequeños y exportables.
- Una vertical slice jugable antes de agregar variedad de contenido.
- Datos y reglas testeables sin depender de animaciones.
- Mantener compatibilidad con Android táctil como criterio de diseño, no como parche final.

## Estrategia de verificación
- `tools/validate_project.py` valida estructura crítica y referencias básicas.
- GitHub Actions ejecuta la validación antes del export.
- El export Android es la prueba de integración mínima obligatoria.
- Cada fase se contrasta contra `spec.md` y `tasks.md` antes de marcarse completa.
