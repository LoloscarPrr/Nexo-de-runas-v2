# Constitución — Nexo de Runas V2

## I. Fidelidad antes que cantidad
Nexo de Runas V2 se reconstruye como una experiencia visual y mecánica inspirada en el Acto 2 de Inscryption. No se aceptan sustitutos de “TCG genérico” cuando exista una referencia aprobada del mockup. Cada pantalla nueva debe conservar jerarquía, densidad, proporciones y sensación pixel-art coherentes con el mockup maestro.

## II. Godot 4 + GDScript como base única
La implementación principal usa Godot 4.x y GDScript. No se mezcla una segunda capa de UI nativa Android para resolver pantallas del juego. Toda lógica jugable debe poder ejecutarse dentro del árbol de escenas de Godot y exportarse a Android desde CI.

## III. Reglas separadas de la presentación
El estado de partida, cartas, recursos, mazos, turnos y resolución de sellos debe vivir separado de la capa visual. Las escenas muestran y envían acciones; no deben convertirse en la fuente de verdad de las reglas. Esto es obligatorio para soportar CPU y, después, multijugador local.

## IV. Modelo de cartas estable
Los recursos admitidos son: Sangre, Huesos, Energía, Runas y Ninguno. La habilidad especial se llama “sello” en toda la interfaz y documentación. Ataque y salud se representan numéricamente. Las cartas deben ser objetos visuales manipulables; no listas de texto disfrazadas de cartas.

## V. Interacción móvil directa
Objetivo primario: Android horizontal 1280×720 de referencia, con escalado responsivo. Los controles deben ser táctiles y explícitos. No se depende de hover. No se mostrará un overlay al deslizar por encima de una carta si la información completa ya está disponible mediante toque.

## VI. Ruta de validación jugable
Primero se valida contra CPU; luego se habilita Wi‑Fi local. El constructor de mazo y la selección de estilo preceden a la conexión local. Ninguna capa de red debe bloquear las pruebas del combate base.

## VII. Build verde como contrato
Todo cambio en `main` debe conservar un proyecto importable y un APK Android exportable. El pipeline valida estructura antes de exportar y falla temprano ante archivos obligatorios ausentes, referencias rotas o conflictos de merge.

## VIII. Spec antes de implementación grande
Todo cambio de alcance relevante debe reflejarse en `spec.md`, `plan.md` y `tasks.md` antes de expandir el código. El orden operativo es: Constitución → Spec → Plan → Tasks → Implementación → Convergencia contra la especificación.

## Criterio de convergencia
Una fase se considera cerrada cuando sus criterios verificables están implementados, el APK se exporta en CI y no existen tareas críticas abiertas de esa fase.
