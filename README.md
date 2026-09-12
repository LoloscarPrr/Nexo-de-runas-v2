# Nexo de Runas V2

Reconstrucción en **Godot 4.3 + GDScript** de Nexo de Runas con una dirección visual y mecánica coherente con el mockup aprobado, priorizando Android horizontal.

## Estado actual
- Export Android Debug APK operativo en GitHub Actions.
- Resolución base: 1280×720.
- Render: GL Compatibility.
- Estructura Spec-Driven incorporada antes de expandir el código.

## Flujo de desarrollo
El proyecto sigue una variante práctica de Spec-Driven Development:

1. `.specify/memory/constitution.md` — principios que no se deben romper.
2. `specs/001-core-reconstruction/spec.md` — qué debe hacer la reconstrucción.
3. `specs/001-core-reconstruction/plan.md` — arquitectura y orden de implementación.
4. `specs/001-core-reconstruction/tasks.md` — backlog verificable.
5. `AGENTS.md` — reglas operativas para agentes de código.

Antes del export Android, CI ejecuta:

```bash
python tools/validate_project.py
```

Ese gate comprueba archivos críticos, escena principal, preset Android y conflictos de merge básicos. El export de Godot continúa siendo la prueba de integración final.

## Prioridad de implementación
Menú → cartas/datos → constructor de mazo → batalla base → CPU → Wi‑Fi local → pulido visual.

La primera meta es una vertical slice jugable contra CPU antes de agregar red local.
