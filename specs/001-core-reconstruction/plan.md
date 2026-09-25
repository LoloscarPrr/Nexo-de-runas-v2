# Plan 001 — Migración al Core Canónico

## Arquitectura objetivo

### 1. Dominio
- `canonical_card_catalog.gd`: 48 cartas, metadatos de dominio/tipo/coste/estadísticas/efectos.
- `canonical_battle_state.gd`: Integridad, Energía, Esencia, mano, mazo, descarte, 4×2 carriles, Sellos, Reliquias y resolución.
- Motor de efectos desacoplado y extensible.
- Estado serializable y determinista.

### 2. Presentación
- Una sola geometría de batalla para cuatro dominios.
- Themes/skins por dominio sin duplicar lógica.
- Cartas reutilizables entre batalla, recompensa, colección y constructor.
- UI touch-first; sin hover obligatorio.

### 3. CPU
- Usa el mismo core y acciones legales.
- Dificultades: Aprendiz, Adepto y Maestro.
- No introducir trampas de reglas exclusivas de CPU salvo encuentros/jefes explícitos.

### 4. Campaña
- Estado separado: dominio, mazo, Guardián, dificultad, mapa, nodos, recompensas y economía.
- Nodos: Combate, Élite, Evento, Fogata, Mercader, Altar, Tesoro y Jefe.

### 5. Multiplayer
- Local y online reutilizan el mismo estado serializable.
- Se implementan después del core/CPU/campaña, pero no se eliminan del diseño.

## Secuencia de implementación
1. Sustituir Constitución/Spec/Plan/Tasks/AGENTS por el canon original.
2. Añadir catálogo canónico de 48 cartas en paralelo al legado.
3. Añadir BattleState canónico con 4 carriles, Integridad, Energía, Descarte, Sellos/Reliquias y pruebas.
4. Implementar motor de efectos y Esencias por dominio.
5. Adaptar Battle UI al nuevo estado manteniendo el layout canónico.
6. Implementar Vs CPU.
7. Migrar Splash, menú principal y menú Jugar.
8. Constructor + Colección.
9. Campaña y nodos.
10. Perfil/Logros/Ajustes.
11. Local.
12. Online.
13. Retirar código legado sólo después de equivalencia funcional y migración de saves.

## Verificación
- `python tools/validate_project.py`.
- Tests legado mientras siga conectado al runtime.
- Tests del core canónico en cada commit.
- Import headless Godot 4.3.
- Export Android firmado por GitHub Actions.
