# Tasks 001 — Reconstrucción núcleo

## Fase 0 — Guardrails
- [x] T001 Establecer constitución del proyecto.
- [x] T002 Crear spec, plan y tasks.
- [x] T003 Agregar validador de estructura al CI.
- [x] T004 Documentar reglas operativas para agentes.

## Fase 1 — Shell y navegación
- [ ] T101 Construir menú principal fiel al mockup.
  - [x] T101a Eliminar pantalla gris y crear shell visual visible.
  - [x] T101b Forzar Android horizontal 1280×720.
  - [ ] T101c Convergencia visual final contra el mockup aprobado.
- [x] T102 Restaurar botones Constructor de mazo, Batalla vs CPU y Batalla local.
- [x] T103 Crear navegación estable entre pantallas sin recargar estado innecesariamente.

## Fase 2 — Cartas y datos
- [ ] T201 Crear `CardData` con nombre, arte, recurso, coste, ataque, salud y sello.
- [ ] T202 Implementar recursos Sangre, Huesos, Energía, Runas y Ninguno.
- [ ] T203 Crear componente visual reutilizable `CardView`.
- [ ] T204 Permitir selección, toque y arrastre táctil.

## Fase 3 — Constructor de mazo
- [ ] T301 Crear biblioteca/colección visual.
- [ ] T302 Crear mazo activo con reordenamiento mediante arrastre.
- [ ] T303 Validar tamaño y reglas del mazo.
- [ ] T304 Implementar selección de uno de cuatro estilos/arquetipos.

## Fase 4 — Batalla base
- [ ] T401 Crear tablero y zonas de cartas.
- [ ] T402 Implementar mano inicial y robo.
- [ ] T403 Implementar turno del jugador.
- [ ] T404 Implementar costes y recursos mínimos.
- [ ] T405 Implementar combate y daño con ataque/salud numéricos.
- [ ] T406 Implementar al menos un sello funcional end-to-end.

## Fase 5 — CPU
- [ ] T501 Crear controlador CPU sobre acciones legales del motor de reglas.
- [ ] T502 Permitir una partida completa contra CPU.
- [ ] T503 Agregar casos de prueba manual reproducibles.

## Fase 6 — Wi‑Fi local
- [ ] T601 Diseñar protocolo de acciones serializables.
- [ ] T602 Crear host/unirse en misma red Wi‑Fi.
- [ ] T603 Sincronizar turnos y recuperar errores de conexión.

## Fase 7 — Convergencia visual
- [ ] T701 Ajustar escala de cartas en Android.
- [ ] T702 Eliminar overlays redundantes de hover/deslizamiento.
- [ ] T703 Revisar todos los menús contra el mockup.
- [ ] T704 Validar APK en dispositivo real y cerrar regresiones.
