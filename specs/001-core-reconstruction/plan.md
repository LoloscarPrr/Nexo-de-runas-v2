# Plan 001 — Migración al Core Canónico

## Arquitectura objetivo

### 1. Domain — reglas y estado
- `canonical_card_catalog.gd`: 48 cartas, metadatos de dominio/tipo/coste/estadísticas/efectos.
- `canonical_battle_state.gd`: Integridad, Energía, Esencia, mano, mazo, descarte, 4×2 carriles, Sellos, Reliquias y resolución.
- Motor de efectos desacoplado y extensible.
- Estado serializable y determinista.
- No depende de UI, Application, Infrastructure ni Presentation.

### 2. Application — casos de uso
- `application/battle/canonical_battle_session.gd` encapsula iniciar batalla, jugar carta, finalizar ronda, inspeccionar unidades y obtener snapshots.
- `application/ports/` declara contratos hacia persistencia/red.
- Presentation y futuros adaptadores de red consumen estos casos de uso; no llaman al Domain directamente.

### 3. Infrastructure — adaptadores externos
- `infrastructure/persistence/json_save_repository.gd` implementa persistencia local versionada.
- Networking, Android y backend futuros viven aquí.
- No contiene reglas del juego.

### 4. Presentation — visual y entrada
- Una sola geometría de batalla para cuatro dominios.
- Themes/skins por dominio sin duplicar lógica.
- Cartas reutilizables entre batalla, recompensa, colección y constructor.
- UI touch-first; sin hover obligatorio.
- `presentation/themes/domain_theme_registry.gd` desacopla identidad visual de reglas.
- Nuevos assets canónicos se integran aquí, no en Domain.

### 5. UI legado
- `scripts/ui/` permanece como adaptador temporal para no romper Android.
- No se agrega nueva lógica de negocio.
- Se reemplaza pantalla por pantalla con Presentation cuando exista equivalencia funcional y visual.

### 6. CPU
- Usa el mismo core y acciones legales.
- Dificultades: Aprendiz, Adepto y Maestro.
- No introducir trampas de reglas exclusivas de CPU salvo encuentros/jefes explícitos.
- Durante la migración la implementación CPU permanece en Domain; puede extraerse luego a un servicio específico sin alterar Presentation.

### 7. Campaña
- Estado separado: dominio, mazo, Guardián, dificultad, mapa, nodos, recompensas y economía.
- Nodos: Combate, Élite, Evento, Fogata, Mercader, Altar, Tesoro y Jefe.
- Guardado mediante un puerto de Application, nunca desde la UI.

### 8. Multiplayer
- Local y online reutilizan comandos/snapshots del mismo Application layer.
- Se implementan después del core/CPU/campaña, pero no se eliminan del diseño.

## Secuencia de implementación
1. Mantener Constitución/Spec/Plan/Tasks/AGENTS alineados al canon original.
2. Añadir catálogo canónico de 48 cartas en paralelo al legado.
3. Añadir BattleState canónico con 4 carriles, Integridad, Energía, Descarte, Sellos/Reliquias y pruebas.
4. Implementar motor de efectos y Esencias por dominio.
5. Introducir Clean Architecture: Application facade, ports, Infrastructure adapters y guard de dependencias.
6. Producir assets canónicos de Bosque bajo `assets/domains/forest/`.
7. Construir el nuevo renderer de batalla en `scripts/presentation/` consumiendo Application.
8. Adaptar los cuatro themes sin cambiar geometría.
9. Migrar Splash, menú principal y menú Jugar a Presentation.
10. Constructor + Colección.
11. Campaña y nodos.
12. Perfil/Logros/Ajustes.
13. Local.
14. Online.
15. Retirar `scripts/ui` y core legado sólo después de equivalencia funcional, visual y migración de saves.

## Verificación
- `python tools/validate_project.py`.
- `tests/clean_architecture_test.gd`.
- Tests de Application e Infrastructure.
- Tests legado mientras siga conectado al runtime.
- Tests del core canónico en cada commit.
- Import headless Godot 4.3.
- Export Android firmado por GitHub Actions.
