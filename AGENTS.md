# AGENTS.md — Reglas para trabajar en Nexo de Runas V2

## Fuente de verdad
Antes de implementar una función grande, leer en este orden:
1. `.specify/memory/constitution.md`
2. `specs/001-core-reconstruction/spec.md`
3. `specs/001-core-reconstruction/plan.md`
4. `specs/001-core-reconstruction/tasks.md`

## Reglas obligatorias
- Mantener Godot 4.x + GDScript.
- La dirección activa es exclusivamente Acto 1: terror de cabaña, mesa física, mapa, sacrificios, objetos, puzzles y jefes.
- No introducir estética pixel-art del Acto 2, pestañas de cuatro facciones ni UI de TCG genérico en el flujo principal.
- Recursos activos del combate: Sangre, Huesos y Ninguno. Ardillas en reserva separada.
- Energía y Runas/Mox quedan fuera de la experiencia actual.
- Usar el término `sello`, no `sigilo`, en UI y documentación del proyecto.
- El mazo principal se construye durante la expedición; no mediante un constructor de cuatro facciones.
- Los sacrificios deben ser una acción explícita del jugador, no un pago automático oculto.
- Mantener reglas y estado separados de UI/3D.
- Diseñar primero para Android horizontal y controles táctiles.
- No introducir comportamientos que dependan exclusivamente de hover.
- Nueva partida y Continuar tienen prioridad sobre modos secundarios.
- Multijugador local se aplaza hasta completar el núcleo del Acto 1.
- No fusionar cambios que rompan el export Android.

## Dirección visual
- Objetivo final: cabaña/mesa 2.5D o 3D con madera, papel envejecido, luz cálida puntual y sombras profundas.
- Los Controls 2D planos pueden usarse únicamente como transición funcional.
- Las cartas deben sentirse como objetos físicos y conservar arte, coste, ataque, salud y sello legibles.

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
- Señales para comunicar presentación → controlador; evitar acoplar nodos visuales al motor de reglas.
- Datos serializables para todo estado persistente o futuro estado de red.

## Política de cambios
Los cambios deben ser incrementales. Si una modificación obliga a reescribir varias capas, dividirla en commits funcionales y mantener una ruta de APK verde entre etapas siempre que sea posible.
