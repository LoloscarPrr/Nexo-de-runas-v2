# Nexo de Runas — Consolidación 00 (2026-11-27)

## Hallazgo y alcance

Comparamos `main` (`0c4fd943`) con `feature/visual-pilot-three-cards` (`e7a0bce4`). GitHub confirma estado **ahead**, 31 commits de avance, **0 behind**, y `main` como merge base. Por lo tanto no existe divergencia de historial ni necesidad de reescribir commits. El candidato reside en `feature/p0-consolidation-20261127` y la rama `main` queda intacta hasta aprobación.

### Preservar sin cambios

- Reglas de Domain, catálogo de 80 cartas (20 por dominio), cinco carriles, costes y balance.
- `scripts/application/battle/canonical_battle_session.gd` y comandos existentes.
- Almacenamiento `JsonSaveRepository` y compatibilidad con archivos de usuario.
- `export_presets.cfg`, identificador Android, firma persistente y la lógica de incremento de `version/code` en CI.
- Artes ya aprobadas, incluido `BS-010 Oso Musgoso` con recorte protegido.

### Cambios mínimos de esta etapa

1. Actualizar la documentación de proyecto para reflejar Android vertical, cuatro dominios y cuatro ilustraciones integradas.
2. Corregir el rótulo de `PILOTO BOSQUE` para incluir Oso Musgoso.
3. Actualizar la prueba existente del menú para proteger la mano inicial de cuatro cartas ilustradas.
4. Añadir `tests/consolidation_00_test.gd`, ejecutado por CI, con comprobaciones del catálogo, los cuatro dominios, la sesión de batalla Application y los recortes de arte.
5. Abrir una PR **en borrador** hacia `main`; no fusionarla hasta verificar Godot, APK firmada y pantalla real Android.

## Aceptación para cerrar etapa 00

- [ ] Importación Godot 4.3 sin errores de parseo.
- [ ] Todas las pruebas automatizadas, incluida `consolidation_00_test.gd`, en verde.
- [ ] Capturas de batalla, colección, mazos y resultado producidas desde la escena real.
- [ ] APK exportada y verificada, misma identidad de aplicación y firma preservada.
- [ ] Prueba física Android: menú, `JUGAR`, `PILOTO BOSQUE`, inspección de Oso, cinco carriles, final de partida, botón Atrás, multitáctil y retorno a menú.
- [ ] Prueba de actualización sobre APK anterior **sin desinstalar** y comprobación de guardados.
- [ ] Revisión de PR y autorización para integrar; luego protección de `main` si procede.

## Deuda técnica que NO debe mezclarse en la consolidación

- Campaña heredada: usa el sistema anterior y no forma un ciclo canónico integrado.
- Selección de dominio y mazo para todos los dominios en la navegación.
- Producción de arte para el resto del catálogo y skins coherentes de Cripta, Torre y Fundición.
- Perfil, logros, ajustes y multijugador aún no terminados.
- Revisar discrepancias en documentos históricos (incluido número de Reliquias) contra la fuente canónica antes de tocar balance; no reinterpretar reglas silenciosamente.

## Próximo paso: Etapa 01

Construir la primera expedición real `menú → mapa → Vs CPU canónico → resultado → recompensa → siguiente nodo` mediante Application/Infrastructure/Presentation, manteniendo Domain sin duplicaciones y con un guardado versionado. La primera entrega debe ser un recorrido funcional, no un mockup independiente.
