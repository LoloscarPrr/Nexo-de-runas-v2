# Plan 001 — Migración al Core Canónico

## Arquitectura objetivo

### 1. Domain — reglas y estado
- `canonical_card_catalog.gd`: 48 cartas, metadatos de dominio/tipo/coste/estadísticas/efectos.
- `definitions/`: definiciones canónicas como `CardDefinition` y, progresivamente, habilidades/efectos.
- `entities/`: `CardInstance`, `BoardState`, `LaneState` y entidades runtime persistibles.
- `value_objects/`: costes, targets, modificadores y objetos pequeños sin identidad propia.
- `events/`: eventos lógicos serializables producidos por el motor.
- `services/`: validadores/resolvers puros como `CostResolver` y, en siguientes etapas, Ability/Effect/Target/Combat resolvers.
- `canonical_battle_state.gd`: Integridad, Energía, Esencia, mano, mazo, descarte, 5×2 carriles, Sellos, Reliquias y resolución durante la transición.
- Estado serializable y determinista.
- No depende de UI, Application, Infrastructure ni Presentation.

### 2. Application — casos de uso
- `application/battle/canonical_battle_session.gd` encapsula iniciar batalla, jugar carta, finalizar ronda, inspeccionar unidades y obtener snapshots.
- `BattleCommand` representa acciones serializables; los métodos públicos de conveniencia delegan en comandos.
- Los resultados de acciones incluyen snapshot y eventos lógicos drenados del Domain.
- `application/ports/` declara contratos hacia persistencia/red.
- Presentation y futuros adaptadores de red consumen estos casos de uso; no llaman al Domain directamente.

### 3. Infrastructure — adaptadores externos
- `infrastructure/persistence/json_save_repository.gd` implementa persistencia local versionada.
- Networking, Android y backend futuros viven aquí.
- No contiene reglas del juego.

### 4. Presentation — visual y entrada
- Android vertical touch-first según mockups aprobados.
- Una sola geometría de batalla de cinco carriles para cuatro dominios.
- Themes/skins por dominio sin duplicar lógica.
- Cartas reutilizables entre batalla, recompensa, colección y constructor.
- UI sin hover obligatorio.
- `presentation/themes/domain_theme_registry.gd` desacopla identidad visual de reglas.
- Nuevos assets canónicos se integran aquí, no en Domain.

### 5. UI legado
- `scripts/ui/` permanece como adaptador temporal para no romper Android.
- No se agrega nueva lógica de negocio.
- Se permiten ajustes mínimos para reflejar reglas del core (como el quinto carril) mientras exista como runtime activo.
- Se reemplaza pantalla por pantalla con Presentation cuando exista equivalencia funcional y visual.

### 6. CPU
- Usa el mismo core, costes, comandos y acciones legales.
- Dificultades: Aprendiz, Adepto y Maestro.
- No introducir trampas de reglas exclusivas de CPU salvo encuentros/jefes explícitos.
- La CPU debe evolucionar hacia un policy/controller que emita los mismos `BattleCommand` que Presentation o networking.

### 7. Campaña
- Estado separado: dominio, mazo, Guardián, dificultad, mapa, nodos, recompensas y economía.
- Las copias de cartas modificables deben tener identidad persistente propia.
- Nodos: Combate, Élite, Evento, Fogata, Mercader, Altar, Tesoro y Jefe.
- Guardado mediante un puerto de Application, nunca desde la UI.

### 8. Multiplayer
- Local y online reutilizan comandos/snapshots/eventos del mismo Application layer.
- Se implementan después del core/CPU/campaña, pero el modelo de datos se mantiene serializable desde ahora.

## Secuencia de implementación
1. Alinear Constitución/Spec/Plan/Tasks/AGENTS a vertical + 5 carriles.
2. Introducir `CardDefinition`, `CardInstance`, `BoardState`, `LaneState`, `CostDefinition`, `CostResolver`, `GameEvent/EventQueue` y `BattleCommand`.
3. Cambiar el core canónico de 4 a 5 carriles usando `BoardState` como fuente de la cantidad.
4. Actualizar Application snapshots/comandos/eventos y pruebas.
5. Ajustar el renderer legado sólo lo necesario para no ocultar el quinto carril.
6. Introducir motor de habilidades/targets/efectos desacoplado y migrar efectos actuales incrementalmente.
7. Construir el renderer vertical en `scripts/presentation/` consumiendo Application.
8. Adaptar los cuatro themes sin cambiar geometría.
9. Migrar Splash, menú principal y menú Jugar a Presentation vertical.
10. Constructor + Colección.
11. Campaña y nodos con identidad de instancia persistente.
12. Perfil/Logros/Ajustes.
13. Local.
14. Online.
15. Cambiar runtime/orientación final cuando Presentation vertical alcance equivalencia.
16. Retirar `scripts/ui` y core legado sólo después de equivalencia funcional, visual y migración de saves.

## Verificación
- `python tools/validate_project.py`.
- `tests/clean_architecture_test.gd`.
- `tests/domain_entity_model_test.gd`.
- Tests de Application e Infrastructure.
- Tests legado mientras siga conectado al runtime.
- Tests del core canónico en cada commit.
- Import headless Godot 4.3.
- Export Android firmado por GitHub Actions.
