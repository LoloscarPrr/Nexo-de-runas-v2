# Nexo de Runas V2

Juego táctico de cartas original para **Android vertical**, desarrollado en **Godot 4.3 / GDScript** con renderizador GL Compatibility. La batalla usa **cinco carriles enfrentados por lado** y el núcleo canónico define **80 cartas fundacionales (20 por dominio)**.

## Estado verificable (consolidación 00)

- Dominios definidos: Bosque Salvaje, Cripta de Hueso, Torre Arcana y Fundición Antigua.
- Core canónico: costes, habilidades, recursos, CPU, mazos oficiales y pruebas Godot.
- Navegación Android actual: menú vertical, batalla Vs CPU de Bosque Salvaje, colección y constructor de mazos de Bosque Salvaje, detalle de cartas y resultado de partida.
- `PILOTO BOSQUE`: cuatro ilustraciones individuales (Brote del Claro, Lobo de Manada, Avatar del Bosque y Oso Musgoso) visibles en la apertura; coste/ataque/vida/efectos vienen de datos canónicos, no de imágenes con texto.
- **No está completado**: expedición canónica de campaña conectada al resultado/recompensas, selección de los cuatro dominios en el menú, acabados visuales de todo el catálogo, perfil, logros ni multijugador.
- La API de guardado, firma persistente y export Android de GitHub Actions deben conservarse; las pruebas no sustituyen el playtest físico.

## Desarrollo seguro

1. Fuente de verdad: `AGENTS.md`, `.specify/memory/constitution.md`, `specs/001-core-reconstruction/` y `docs/CLEAN_ARCHITECTURE.md`.
2. Rama `main`: no fusionar cambios sin pruebas y aprobación visual Android.
3. Rama de consolidación: `feature/p0-consolidation-20261127`. Ver `docs/CONSOLIDACION_00.md`.
4. Ejecutar `python tools/validate_project.py` y la batería de pruebas GDScript con Godot 4.3 antes del export.
5. GitHub Actions: `.github/workflows/android-build.yml` produce renders y una APK Android firmada por la configuración actual. No cambiar aplicación/paquete/firma de forma incompatible.

## Próximo hito

**Expedición vertical completa:** menú → dominio/mazo → batalla canónica → resultado → recompensa → mapa → siguiente nodo, con progreso persistente. En esta etapa evitar añadir reglas duplicadas a `scripts/ui/` legado.
