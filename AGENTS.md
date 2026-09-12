# AGENTS.md — Reglas para trabajar en Nexo de Runas V2

## Fuente de verdad
Antes de implementar una función grande, leer en este orden:
1. `.specify/memory/constitution.md`
2. `specs/001-core-reconstruction/spec.md`
3. `specs/001-core-reconstruction/plan.md`
4. `specs/001-core-reconstruction/tasks.md`

## Reglas obligatorias
- Mantener Godot 4.x + GDScript.
- No reemplazar la estética aprobada por componentes de TCG genérico.
- Usar el término `sello`, no `sigilo`, en UI y documentación del proyecto.
- Recursos de cartas: Sangre, Huesos, Energía, Runas y Ninguno.
- Mantener reglas y estado separados de la UI.
- Diseñar primero para Android horizontal y controles táctiles.
- No introducir comportamientos que dependan exclusivamente de hover.
- El modo CPU debe seguir funcionando aunque la capa de red esté incompleta.
- No fusionar cambios que rompan el export Android.

## Flujo de trabajo
1. Actualizar spec/plan/tasks si cambia el alcance.
2. Implementar la unidad mínima coherente.
3. Ejecutar `python tools/validate_project.py`.
4. Confirmar que Godot puede importar/exportar el proyecto.
5. Marcar tareas completadas solo cuando el criterio sea observable en el APK.

## Convenciones
- Escenas: `snake_case.tscn`.
- Scripts: `snake_case.gd`.
- Clases con `class_name` cuando sean parte del dominio reutilizable.
- Señales para comunicar UI → controlador; evitar acoplar nodos visuales al motor de reglas.
- Datos serializables para todo estado que deba viajar por red local.

## Política de cambios
Los cambios deben ser incrementales. Si una modificación obliga a reescribir varias capas, dividirla en commits funcionales y mantener una ruta de APK verde entre etapas siempre que sea posible.
