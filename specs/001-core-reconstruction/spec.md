# Spec 001 — Nexo de Runas V2 · Core canónico original

## Objetivo
Migrar Nexo de Runas V2 desde el prototipo legado inspirado en Acto 1 hacia el juego original definido en el Documento Maestro Canónico v1.0, manteniendo Godot 4 + GDScript, Android horizontal, firma persistente, saves y un pipeline verde.

## Dirección visual obligatoria
- Splash: cuatro dominios alrededor del Nexo.
- Menú principal: Jugar, Constructor de Mazos, Colección, Perfil, Logros y Ajustes.
- Menú Jugar: Campaña, Vs CPU, Jugar Local, Jugar Online y Volver.
- Batalla: una única plantilla canónica compartida por los cuatro dominios.
- Exactamente 4 carriles por lado; sin carriles falsos decorativos.
- Mano abajo; Finalizar turno abajo a la derecha.
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
11. Máximo 3 Sellos y 2 Reliquias activas.
12. Descarte público.
13. Mazo agotado produce Inestabilidad 1, 2, 3... de daño por robo fallido.

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
- Sello: permanente, máximo 3.

## Palabras clave universales iniciales
Carga, Emboscada, Blindaje X, Guardia, Último Aliento, Exhumar y Canalizar X.

## Catálogo inicial
48 cartas canónicas: 12 por dominio. Cuatro mazos predeterminados de 20 cartas: Manada Verde, Osario Eterno, Círculo Astral y Máquina Roja.

## Campaña
Elegir dominio → mazo/Guardián/dificultad → mapa → nodos. Nodos canónicos: Combate, Élite, Evento, Fogata/Mejora, Mercader, Altar de Sellos, Tesoro y Jefe.

## Requisitos técnicos
- Godot 4.3 + GDScript.
- Estado desacoplado de UI.
- Datos serializables.
- Android horizontal.
- Guardado versionado.
- Firma persistente.
- CI Android verde.

## Estrategia de migración
El motor antiguo permanece temporalmente para no romper el APK. Se introduce un core canónico paralelo con catálogo y pruebas propias. La UI se conecta al nuevo core sólo cuando esa capa esté verde.

## Primera vertical slice del nuevo rumbo
Core canónico + 48 cartas → batalla Vs CPU funcional de un dominio → misma batalla con skin de los cuatro dominios → constructor/colección → campaña básica → migración de UI principal.
