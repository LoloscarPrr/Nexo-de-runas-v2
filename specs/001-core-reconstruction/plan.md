# Plan 001 — Migración al Core Canónico

## Arquitectura objetivo

### 1. Domain — reglas y estado
- `canonical_card_catalog.gd`: 48 cartas, metadatos de dominio/tipo/coste/estadísticas/efectos.
- `canonical_ability_catalog.gd`: habilidades declarativas que enlazan los `effect_id` de carta con trigger, condiciones, target y efectos atómicos.
- `definitions/`: definiciones canónicas como `CardDefinition`, `AbilityDefinition` y `EffectDefinition`.
- `entities/`: `CardInstance`, `BoardState`, `LaneState` y entidades runtime persistibles.
- `value_objects/`: costes, `TargetSpec`, `ConditionDefinition`, modificadores y objetos pequeños sin identidad propia.
- `events/`: eventos lógicos serializables producidos por el motor.
- `services/`: `CostResolver`, `TargetResolver`, `ConditionResolver`, `AbilityResolver` y `EffectResolver`; combate/turnos se extraen progresivamente.
- `canonical_battle_state.gd`: Integridad, Energía, Esencia, mano, mazo, descarte, 5×2 carriles, Sellos, Reliquias y resolución durante la transición.
- Las habilidades migradas se ejecutan por datos; `CanonicalBattleState` no contiene listas de IDs para Ritos, entradas al tablero o Último Aliento ya migrados.
- Estado serializable y determinista.
- No depende de UI, Application, Infrastructure ni Presentation.

### 2. Application — casos de uso
- `application/battle/canonical_battle_session.gd` encapsula iniciar batalla, jugar carta, finalizar ronda, inspeccionar unidades y obtener snapshots.
- `BattleCommand` representa acciones serializables; los métodos públicos de conveniencia delegan en comandos.
- Los resultados de acciones incluyen snapshot y eventos lógicos drenados del Domain.
- La selección de objetivos consulta `TargetSpec`/`AbilityResolver` y no mantiene listas de nombres de carta.
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
- Usa el mismo core, costes y acciones legales.
- Dificultades: Aprendiz, Adepto y Maestro.
- No introducir trampas de reglas exclusivas de CPU salvo encuentros/jefes explícitos.
- La CPU debe evolucionar hacia un policy/controller que emita los mismos `BattleCommand` que Presentation o networking.
- La primera integración de `AbilityResolver` resuelve el lado del jugador; la siguiente extensión debe hacer relativos al controlador los recursos/targets para que CPU, Local y Online recorran exactamente la misma ruta.

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
6. Introducir `AbilityDefinition`, `TargetSpec`, `ConditionDefinition`, `EffectDefinition`, sus resolvers y migrar los efectos actualmente implementados de Ritos/entrada/Último Aliento a datos declarativos.
7. Generalizar el contexto de habilidad para controlador/lado y conectar la CPU a los mismos comandos/resolvers.
8. Construir el renderer vertical en `scripts/presentation/` consumiendo Application.
9. Adaptar los cuatro themes sin cambiar geometría.
10. Migrar Splash, menú principal y menú Jugar a Presentation vertical.
11. Constructor + Colección.
12. Campaña y nodos con identidad de instancia persistente.
13. Perfil/Logros/Ajustes.
14. Local.
15. Online.
16. Cambiar runtime/orientación final cuando Presentation vertical alcance equivalencia.
17. Retirar `scripts/ui` y core legado sólo después de equivalencia funcional, visual y migración de saves.

## Verificación
- `python tools/validate_project.py`.
- `tests/clean_architecture_test.gd`.
- `tests/domain_entity_model_test.gd`.
- `tests/ability_effect_engine_test.gd`.
- Tests de Application e Infrastructure.
- Tests legado mientras siga conectado al runtime.
- Tests del core canónico en cada commit.
- Import headless Godot 4.3.
- Export Android firmado por GitHub Actions.
