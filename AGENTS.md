# AGENTS.md — Reglas para trabajar en Nexo de Runas V2

## Fuente de verdad
Antes de implementar una función grande, leer en este orden:
1. `.specify/memory/constitution.md`
2. `specs/001-core-reconstruction/spec.md`
3. `specs/001-core-reconstruction/plan.md`
4. `specs/001-core-reconstruction/tasks.md`
5. Documento Maestro Canónico v1.0 de Fuentes, cuando esté disponible en el contexto del proyecto.

## Dirección activa
- Nexo de Runas es un juego original de cartas tácticas para Android horizontal.
- La dirección anterior de réplica del Acto 1 queda archivada y no debe gobernar nuevas funciones.
- Los cuatro dominios activos son Bosque Salvaje, Cripta de Hueso, Torre Arcana y Fundición Antigua.
- La UI y el arte deben seguir los mockups canónicos aprobados: fantasía oscura premium, materiales físicos, runas, profundidad e iluminación cinematográfica.
- La batalla usa exactamente cuatro carriles por lado y una arquitectura HUD compartida por los cuatro dominios.
- Usar siempre el término `sello`, nunca `sigilo`, en UI y documentación nueva.

## Reglas jugables activas
- Integridad inicial del Nexo: 20.
- Mazo base: 20 cartas + 1 Guardián externo.
- Mano inicial: 4; máximo de mano: 8.
- Energía Rúnica: capacidad progresiva 1→6 y recarga completa por turno.
- 6 es el máximo estándar; 12 es límite absoluto extraordinario mediante efectos.
- Máximo 3 Sellos y 2 Reliquias activas.
- Recursos por dominio: Instinto, Restos, Conocimiento y Calor.
- El set mínimo canónico inicial contiene 48 cartas: 12 por dominio.

## Arquitectura
- Mantener Godot 4.x + GDScript.
- Reglas y estado separados de UI/3D.
- Datos serializables para guardado, CPU y futura red.
- La presentación observa el estado y emite acciones; nunca decide resultados.
- Diseñar primero para Android horizontal y controles táctiles.
- No introducir comportamiento esencial dependiente de hover.

## Migración desde el motor antiguo
- El motor Acto 1 existente puede permanecer temporalmente para mantener el APK verde.
- El nuevo core canónico debe implementarse en paralelo y cubrirse con pruebas antes de reemplazar la UI/flujo legado.
- No borrar firma Android, saves existentes ni pipeline mientras dure la migración.
- Los assets del set antiguo pueden permanecer como compatibilidad temporal; no definen el catálogo canónico nuevo.

## Flujo principal objetivo
Splash → Menú principal → Jugar → Campaña / Vs CPU / Local / Online.
El menú principal también expone Constructor de Mazos, Colección, Perfil, Logros y Ajustes.

## Flujo de trabajo
1. Actualizar spec/plan/tasks si cambia el alcance.
2. Implementar la unidad mínima coherente.
3. Ejecutar `python tools/validate_project.py`.
4. Ejecutar las pruebas GDScript del core canónico.
5. Confirmar import/export con Godot 4.3.
6. Mantener APK Android verde.

## Convenciones
- Escenas: `snake_case.tscn`.
- Scripts: `snake_case.gd`.
- Clases reutilizables con `class_name`.
- Señales para presentación → controlador.
- Cambios incrementales, con una ruta exportable entre etapas.
