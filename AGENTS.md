# AGENTS.md — Reglas para trabajar en Nexo de Runas V2

## Fuente de verdad
Antes de implementar una función grande, leer en este orden:
1. `.specify/memory/constitution.md`
2. `specs/001-core-reconstruction/spec.md`
3. `specs/001-core-reconstruction/plan.md`
4. `specs/001-core-reconstruction/tasks.md`
5. `docs/CLEAN_ARCHITECTURE.md`
6. Documento Maestro Canónico v1.0 de Fuentes, cuando esté disponible en el contexto del proyecto.
7. Mockups verticales canónicos aprobados del 30-09-2026 para composición visual e interacción.

## Dirección activa
- Nexo de Runas es un juego original de cartas tácticas para Android vertical.
- La dirección anterior de réplica del Acto 1 queda archivada y no debe gobernar nuevas funciones.
- Los cuatro dominios activos son Bosque Salvaje, Cripta de Hueso, Torre Arcana y Fundición Antigua.
- La UI y el arte deben seguir los mockups verticales canónicos aprobados: fantasía oscura premium, materiales físicos, runas, profundidad e iluminación cinematográfica.
- La batalla usa exactamente cinco carriles por lado y una arquitectura HUD compartida por los cuatro dominios.
- Usar siempre el término `sello`, nunca `sigilo`, en UI y documentación nueva.
- El runtime horizontal legado puede permanecer temporalmente mientras se migra a Presentation; no es fuente de verdad para UI nueva.

## Reglas jugables activas
- Integridad inicial del Nexo: 20.
- Mazo base: 20 cartas + 1 Guardián externo.
- Mano inicial: 4; máximo de mano: 8.
- Energía Rúnica: capacidad progresiva 1→6 y recarga completa por turno.
- 6 es el máximo estándar; 12 es límite absoluto extraordinario mediante efectos.
- Máximo 3 Sellos y 2 Reliquias activas.
- Recursos por dominio: Instinto, Restos, Conocimiento y Calor.
- El set mínimo canónico inicial contiene 48 cartas: 12 por dominio.
- Los cinco carriles enfrentados comparten índice lógico y deben ser tratados como datos, no como cinco controles hardcodeados independientes.

## Modelo de dominio nuevo
- Separar `CardDefinition` (plantilla canónica) de `CardInstance` (copia concreta con identidad y estado propios).
- `BoardState` es la fuente de verdad de cantidad/estructura de carriles; el valor canónico es 5.
- `LaneState` representa una posición lógica y no conoce sprites ni nodos visuales.
- Costes se expresan como `CostDefinition`/componentes y se validan/pagan mediante servicios de Domain.
- Application expresa acciones mediante comandos serializables; Domain produce eventos lógicos serializables.
- Presentation interpreta snapshots/eventos para animar; nunca decide reglas.
- CPU, Local y Online deben emitir las mismas acciones legales que un jugador humano.

## Clean Architecture obligatoria para código nuevo
Las dependencias apuntan hacia adentro:

`Presentation → Application → Domain`

`Infrastructure → Application Ports`

### Domain — `scripts/domain/`
- Reglas, estado, definiciones, entidades, value objects, eventos y servicios puros del juego.
- No puede importar Application, Infrastructure, Presentation ni `scripts/ui`.
- No conoce escenas, botones, sprites, assets, archivos ni red.

### Application — `scripts/application/`
- Casos de uso, comandos y orquestación.
- Puede depender de Domain.
- No puede depender de Infrastructure, Presentation ni `scripts/ui`.
- La presentación recibe snapshots/DTOs/eventos y emite comandos mediante esta capa.

### Infrastructure — `scripts/infrastructure/`
- Persistencia, networking, Android y adapters externos.
- Implementa puertos declarados en Application.
- No contiene reglas de juego ni composición visual.

### Presentation — `scripts/presentation/`
- Pantallas, HUD, themes, assets, animaciones y shaders.
- Puede depender de Application.
- No importa Domain directamente.
- La nueva producción de assets canónicos debe integrarse aquí.

### `scripts/ui/` legado
- Se conserva temporalmente para mantener el APK verde.
- No introducir nueva lógica de negocio aquí.
- Puede recibir ajustes de compatibilidad visual necesarios para reflejar reglas ya migradas (por ejemplo, cinco carriles), pero no nuevas reglas.
- Migrar pantalla por pantalla hacia `scripts/presentation`.
- Retirar sólo cuando el reemplazo esté probado y conectado.

## Assets canónicos
La producción nueva se organiza por dominio:

`assets/common/`

`assets/domains/forest/{battle,cards,hud,fx,menu}`

`assets/domains/crypt/{battle,cards,hud,fx,menu}`

`assets/domains/tower/{battle,cards,hud,fx,menu}`

`assets/domains/forge/{battle,cards,hud,fx,menu}`

La geometría de batalla es compartida; los assets y Theme cambian por dominio.

## Migración desde el motor antiguo
- El motor Acto 1 existente puede permanecer temporalmente para mantener el APK verde.
- El nuevo core canónico debe implementarse en paralelo y cubrirse con pruebas antes de reemplazar la UI/flujo legado.
- No borrar firma Android, saves existentes ni pipeline mientras dure la migración.
- Los assets del set antiguo pueden permanecer como compatibilidad temporal; no definen el catálogo canónico nuevo.
- Migrar primero reglas y entidades; después Presentation vertical; luego cambiar orientación/runtime final.

## Flujo principal objetivo
Splash → Menú principal → Jugar → Campaña / Vs CPU / Local / Online.
El menú principal también expone Constructor de Mazos, Colección, Perfil, Logros y Ajustes.

## Flujo de trabajo
1. Actualizar Spec/Plan/Tasks si cambia el alcance.
2. Implementar la unidad mínima coherente.
3. Respetar `docs/CLEAN_ARCHITECTURE.md`.
4. Ejecutar `python tools/validate_project.py`.
5. Ejecutar `tests/clean_architecture_test.gd` y tests de la capa modificada.
6. Ejecutar las pruebas GDScript del core canónico y del modelo de entidades.
7. Confirmar import/export con Godot 4.3.
8. Mantener APK Android verde.

## Convenciones
- Escenas: `snake_case.tscn`.
- Scripts: `snake_case.gd`.
- Clases reutilizables con `class_name`.
- Señales para presentación → controlador.
- Cambios incrementales, con una ruta exportable entre etapas.
- No crear abstracciones sin consumidor real; Clean Architecture debe reducir acoplamiento, no aumentar ceremonia.
