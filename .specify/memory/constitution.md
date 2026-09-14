# Constitución — Nexo de Runas V2

## I. Acto 1 como única dirección activa
La prioridad actual de Nexo de Runas V2 es reproducir la experiencia del Acto 1 de Inscryption tan fielmente como sea razonable dentro del proyecto: terror de cabaña, mesa física, cartas orgánicas, sacrificios, mapa de expedición, objetos, encuentros, puzzles y jefes. La estética, estructura de facciones y presentación del Acto 2 quedan fuera de la dirección activa hasta que el usuario pida explícitamente retomarlas.

## II. Atmósfera de terror antes que interfaz de TCG
La presentación final no debe parecer un TCG moderno, un menú de colección ni una pantalla pixel-art del Acto 2. El objetivo visual es madera oscura, papel envejecido, sombras, luz cálida puntual, profundidad, sensación de mesa física y cabaña inquietante. La transición puede usar UI 2D temporal, pero la meta es una puesta en escena 2.5D/3D coherente con el Acto 1.

## III. Núcleo mecánico del Acto 1
El combate activo usa cuatro carriles, balanza, mazo principal, reserva de ardillas, Sangre mediante sacrificios y Huesos obtenidos por muertes/sacrificios. Energía, Mox/Runas y las facciones de Tecnología/Magia/No-muertos no forman parte del núcleo actual. La habilidad especial se llama `sello` en la interfaz de Nexo de Runas.

## IV. El mazo se construye dentro de la expedición
No habrá un constructor de mazo por cuatro facciones en el flujo principal del Acto 1. El mazo progresa mediante elecciones de carta, fogatas, sacrificios, talladores/tótems, intercambios, objetos y demás encuentros de ruta. El antiguo constructor libre puede conservarse únicamente como herramienta de depuración mientras se migra, pero no define la experiencia final ni debe aparecer como ruta principal.

## V. Campaña primero
Nueva partida y Continuar deben llevar directamente a la experiencia del Acto 1. El mapa, combates, eventos, derrota, reinicio, jefes, puzzles y exploración de la cabaña tienen prioridad sobre multijugador local u otros modos. El multijugador queda aplazado hasta estabilizar el Acto 1.

## VI. Reglas separadas de la presentación
El estado de partida, cartas, mazos, sacrificios, recursos, turnos, sellos, mapa y progreso deben vivir separados de la UI y de la escena 3D. La presentación observa y emite acciones; no es la fuente de verdad de las reglas. Esto permite CPU, guardado y futuras capas de red sin reescribir el motor.

## VII. Interacción móvil directa
Objetivo primario: Android horizontal 1280×720 de referencia, con escalado responsivo y controles táctiles. No se depende de hover. Sacrificar, robar, jugar cartas, elegir rutas, inspeccionar objetos y resolver puzzles debe ser cómodo con toque.

## VIII. Build verde como contrato
Todo cambio en `main` debe conservar un proyecto importable y un APK Android exportable. El pipeline valida estructura antes de exportar y falla temprano ante archivos obligatorios ausentes, referencias rotas o conflictos de merge.

## IX. Spec antes de implementación grande
Todo cambio de alcance relevante debe reflejarse en `spec.md`, `plan.md` y `tasks.md` antes de expandir el código. El orden operativo es: Constitución → Spec → Plan → Tasks → Implementación → Convergencia contra la especificación.

## Criterio de convergencia
Una fase se considera cerrada cuando sus criterios verificables están implementados, el APK exporta en CI y la experiencia observable se acerca al Acto 1 sin introducir estética o sistemas del Acto 2 en el flujo principal.
