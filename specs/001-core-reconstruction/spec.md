# Spec 001 — Nexo de Runas V2 · Core canónico original

## Objetivo
Migrar Nexo de Runas V2 desde el prototipo legado inspirado en Acto 1 hacia el juego original definido en el Documento Maestro Canónico v1.0 y los mockups verticales aprobados del 30-09-2026, manteniendo Godot 4.3 + GDScript, Android, firma persistente, saves y un pipeline verde.

## Dirección visual obligatoria
- Android vertical y touch-first como objetivo final.
- Los mockups aprobados de 941×1672 son la referencia de composición; el layout debe escalar de forma responsiva.
- Splash: cuatro dominios alrededor del Nexo.
- Menú principal: Jugar, Constructor de Mazos, Colección, Perfil, Logros y Ajustes.
- Menú Jugar: Campaña, Vs CPU, Jugar Local, Jugar Online y Volver.
- Batalla: una única plantilla canónica compartida por los cuatro dominios.
- Exactamente 5 carriles por lado; sin carriles falsos decorativos.
- Mano abajo; Finalizar turno en la zona inferior de acción definida por el mockup vertical.
- Integridad, Energía, Esencia, Sellos, Reliquias, Mazo y Descarte visibles.
- Estética dark fantasy premium y física; el dominio cambia el skin, no la geometría de la UI.

## Reglas de batalla
1. Integridad inicial: 20.
2. Mazo: 20 cartas + Guardián externo.
3. Mano inicial: 4; máximo 8.
4. Mulligan: hasta 2 cartas, una vez.
5. Energía: capacidad 1→6, recarga completa por turno.
6. Límite absoluto de Energía: 12 mediante efectos.
7. Segundo jugador: Runa de Impulso, +1 Energía temporal una vez por partida.
8. Criatura recién invocada no ataca salvo Carga.
9. Combate criatura contra criatura simultáneo, salvo Emboscada.
10. Carril sin defensor inflige daño directo al Nexo.
11. Los cinco carriles están indexados de forma simétrica entre jugador y rival.
12. Máximo 3 Sellos y 2 Reliquias activas.
13. Descarte público.
14. Mazo agotado produce Inestabilidad 1, 2, 3... de daño por robo fallido.

## Dominios y recursos
- Bosque Salvaje / Instinto (máx. 5): posición, Manada y presión.
- Cripta de Hueso / Restos (máx. 6): muerte, Descarte y Exhumar.
- Torre Arcana / Conocimiento (máx. 5): Revelar, Eco y Canalizar.
- Fundición Antigua / Calor (máx. 6): Constructos, Ensamblar y Sobrecalentar.
- Sobrecarga: terminar en 6 Calor causa 1 daño al Nexo y baja Calor a 3.

## Tipos de carta
- Criatura: ocupa carril, normalmente ATQ/SAL.
- Rito: efecto inmediato y luego Descarte.
- Reliquia: permanente, máximo 2.
- Sello: permanente, máximo 3 mientras se cierra la nomenclatura final de habilidades/permanentes.

## Modelo de entidades
### CardDefinition
Plantilla canónica inmutable durante la partida. Contiene identidad, nombre, dominio, tipo, estadísticas base, coste, tags/palabras clave y referencias a habilidades/efectos.

### CardInstance
Copia concreta de una `CardDefinition`. Tiene `instance_id` propio, propietario, controlador, zona, salud/estado actual, modificadores y estados. Dos copias del mismo `definition_id` deben poder evolucionar de forma independiente.

### BoardState / LaneState
`BoardState` define la geometría lógica del combate. Tiene exactamente cinco `LaneState` por lado. Presentation no decide la cantidad de carriles.

### CostDefinition / CostResolver
Los costes son datos compuestos y el motor decide si son pagables. La primera integración canónica cubre Energía y Esencia, dejando el modelo preparado para componentes adicionales sin reescribir `play_card`.

### AbilityDefinition
Describe una habilidad sin escribir lógica específica para el nombre de una carta. Contiene `trigger`, condiciones, un `TargetSpec` y una lista ordenada de `EffectDefinition`.

### TargetSpec
Declara si una habilidad no necesita selección, necesita una unidad aliada, una unidad enemiga o un espacio libre automático. Application consulta este dato para decidir qué carriles son objetivos legales; Presentation no mantiene listas manuales de cartas.

### ConditionDefinition / ConditionResolver
Una condición responde si una habilidad puede activarse o resolver su objetivo. La primera versión cubre condiciones como “existe otra Bestia aliada”, “el objetivo tiene tag CONSTRUCTO” y “el Descarte contiene una criatura de coste permitido”.

### EffectDefinition / EffectResolver
Un efecto es una operación atómica reutilizable. La primera versión implementa ganar Esencia/recurso, robar, hacer daño, modificar estadísticas, matar, invocar token, revelar cartas y devolver criatura desde Descarte.

### AbilityResolver
Orquesta `Trigger → TargetResolver → ConditionResolver → EffectResolver`. Emite `ABILITY_TRIGGERED` y `EFFECT_RESOLVED` para que Presentation pueda animar lo sucedido sin decidir reglas.

### BattleCommand
Application expresa acciones del jugador/CPU/red mediante comandos serializables (`play_card`, `end_round`, etc.). Los métodos de conveniencia existentes pueden delegar en comandos durante la migración.

### GameEvent
Domain produce eventos lógicos (`CARD_PLAYED`, `RESOURCE_SPENT`, `UNIT_DIED`, `ABILITY_TRIGGERED`, `EFFECT_RESOLVED`, `TURN_STARTED`, etc.). Presentation los usa para animar; los eventos no contienen nodos, sprites ni referencias visuales.

## Palabras clave universales iniciales
Carga, Emboscada, Blindaje X, Guardia, Último Aliento, Exhumar y Canalizar X.

## Catálogo inicial
48 cartas canónicas: 12 por dominio. Cuatro mazos predeterminados de 20 cartas: Manada Verde, Osario Eterno, Círculo Astral y Máquina Roja.

El `canonical_ability_catalog.gd` inicial contiene 15 habilidades declarativas correspondientes a los efectos que ya estaban implementados en el prototipo canónico: entradas al tablero, Ritos y Últimos Alientos de los cuatro dominios. Nuevas cartas no deben añadir `match card_id` a `CanonicalBattleState`.

## Campaña
Elegir dominio → mazo/Guardián/dificultad → mapa → nodos. Nodos canónicos: Combate, Élite, Evento, Fogata/Mejora, Mercader, Altar de Sellos, Tesoro y Jefe.

Las mejoras de campaña deben dirigirse a instancias concretas o a modificaciones persistibles explícitas; no se deben aplicar accidentalmente a todas las copias que compartan `card_id`.

## Arquitectura de efectos — estado actual
La migración es incremental, pero la base ya está operativa:
1. entidades, costes, comandos y eventos formalizados;
2. `AbilityDefinition`, `TargetSpec`, `ConditionDefinition` y `EffectDefinition` implementados;
3. `TargetResolver`, `ConditionResolver`, `AbilityResolver` y `EffectResolver` implementados;
4. los `match card_id` activos de Ritos, entrada al tablero y Último Aliento fueron extraídos de `CanonicalBattleState`;
5. Application consulta metadata de objetivo en lugar de mantener listas de IDs.

Pendiente: hacer relativo al controlador el contexto completo de recursos/targets para que CPU, Local y Online ejecuten exactamente las mismas habilidades desde ambos lados, y completar las mecánicas de dominio todavía no implementadas (Manada avanzada, Eco, Ensamblar, etc.).

## Requisitos técnicos
- Godot 4.3 + GDScript.
- Estado desacoplado de UI.
- Datos serializables.
- Android vertical como destino canónico final.
- Guardado versionado.
- Firma persistente.
- CI Android verde.
- El runtime horizontal legado puede permanecer temporalmente hasta que la Presentation vertical tenga equivalencia funcional.

## Estrategia de migración
El motor antiguo permanece temporalmente para no romper el APK. Se introduce y refina un core canónico paralelo con catálogo, entidades y pruebas propias. La UI vertical nueva se conecta al nuevo core mediante Application sólo cuando esa capa esté verde.

## Primera vertical slice del nuevo rumbo
Core canónico + entidades + 48 cartas + motor declarativo de habilidades → batalla Vs CPU funcional de un dominio con 5 carriles → renderer vertical basado en mockup → misma batalla con skin de los cuatro dominios → constructor/colección → campaña básica → migración de UI principal.
