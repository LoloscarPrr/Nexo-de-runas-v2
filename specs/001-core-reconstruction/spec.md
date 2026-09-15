# Spec 001 — Nexo de Runas V2 · Reconstrucción enfocada en Acto 1

## Objetivo
Reconstruir Nexo de Runas V2 en Godot 4 + GDScript como una experiencia centrada casi exclusivamente en el Acto 1 de Inscryption: terror de cabaña, mesa física, mapa de expedición, sacrificios, selección progresiva de cartas, objetos, eventos, puzzles y jefes. El Acto 2 queda fuera del alcance activo.

## Dirección visual obligatoria
- Nada del flujo principal debe verse como el Acto 2 ni como un TCG de colección.
- Objetivo: cabaña oscura, madera, papel envejecido, iluminación cálida puntual, sombras profundas, texturas sucias y sensación física de mesa/cartas.
- La interfaz 2D plana existente es transitoria. La meta es una puesta en escena 2.5D/3D en Godot para menú, mesa y cabaña.
- Las cartas deben sentirse como objetos físicos: marco orgánico, arte central, coste, ataque, salud y sello legibles.
- No usar pestañas de Bestias / No-muertos / Tecnología / Magia en el flujo del Acto 1.

## Alcance funcional principal
1. Inicio con `Nueva partida` y `Continuar` como rutas principales.
2. Expedición con mapa ramificado y nodos accesibles según posición.
3. Mazo de campaña propio, persistente durante la expedición.
4. Reserva de ardillas separada del mazo principal.
5. Combate de cuatro carriles con balanza.
6. Sangre obtenida mediante sacrificios voluntarios de criaturas propias.
7. Huesos obtenidos por muertes/sacrificios y consumidos por cartas que los requieran.
8. Robo por turno eligiendo entre mazo principal y reserva de ardillas cuando corresponda.
9. Selección de cartas, fogatas, eventos de sacrificio, objetos y encuentros de ruta.
10. Jefes con patrones/fases propias y avance entre regiones.
11. Derrota, reinicio y guardado/continuar sin duplicar recompensas.
12. Exploración de cabaña y puzzles persistentes en fases posteriores de la reconstrucción.

## Modelo de cartas activo
- Recursos permitidos en el núcleo actual: `Sangre`, `Huesos` y `Ninguno`.
- `Energía`, `Runas/Mox` y sistemas de facciones del Acto 2 quedan desactivados del flujo principal.
- La habilidad especial se llama `sello` en Nexo de Runas.
- Ataque y salud se muestran numéricamente.
- Las cartas se manipulan por toque; ninguna acción esencial depende de hover.

## Construcción del mazo
- No existe un constructor libre de cuatro facciones como parte de la experiencia principal.
- El mazo se modifica dentro de la expedición por elecciones y eventos.
- El antiguo constructor puede quedar temporalmente en código como herramienta de depuración, pero debe quedar oculto del menú principal mientras dure la reconstrucción del Acto 1.

## Combate mínimo aceptable
- Mano inicial funcional.
- Reserva de ardillas.
- Selección de carta.
- Selección explícita de sacrificios para pagar Sangre.
- Colocación en uno de cuatro carriles.
- Huesos al morir/sacrificar criaturas.
- Ataques por carril y daño a la balanza si no hay bloqueador.
- Victoria a +5 y derrota a -5.
- CPU con cola/patrón de cartas visibles o predecibles según el encuentro.

## Requisitos técnicos
- Godot 4.x + GDScript.
- Android horizontal 1280×720 de referencia.
- Estado y reglas desacoplados de UI/3D.
- Guardado versionado.
- Exportación Android automática por GitHub Actions.
- Validación estructural previa al export.

## Fuera de alcance actual
- Estética o campaña del Acto 2.
- Facciones Tecnología/Magia/No-muertos como sistemas independientes.
- Multijugador local visible en el menú principal.
- Matchmaking por Internet.
- Monetización.

## Primera vertical slice del nuevo rumbo
`Nueva partida → mapa físico/oscuro → elección de carta orgánica → combate con Sangre y sacrificios → recompensa → fogata → regreso al mapa → guardar y continuar`.

La vertical slice no se considera convergida mientras conserve elementos visuales o mecánicos claramente heredados del Acto 2 en el flujo principal.

## Iteración de mesa táctil — septiembre 2026
- Cuatro casillas propias frente a cuatro rivales; se conservan los cuatro carriles del dominio.
- Balanza gráfica izquierda enlazada al daño real, oponente a la derecha y mesa en perspectiva.
- Mano inferior desplazable, siempre visible; mazo y Ardillas separados y visibles.
- Selección y cancelación de sacrificios sin consumir criaturas hasta confirmar la colocación.
- Cartas de papel con silueta de tinta, coste, ataque, salud actual y sello.
