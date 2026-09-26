# Tasks 001 — Core canónico original

## Fase A — Rebasar fuente de verdad
- [x] A001 Constitución actualizada al juego original.
- [x] A002 Spec y plan actualizados al Documento Maestro Canónico v1.0.
- [x] A003 AGENTS actualizado para cuatro dominios y nuevo reglamento.

## Fase B — Core de datos
- [x] B101 Crear catálogo canónico de 48 cartas.
- [x] B102 Exponer 12 cartas por dominio y 4 mazos iniciales de 20.
- [x] B103 Validar IDs, tipos, costes, dominios y límites de copias.
- [x] B104 Mantener catálogo legado aislado durante migración.

## Fase C — BattleState canónico
- [x] C201 4 carriles exactos por lado.
- [x] C202 Integridad 20/20 y daño directo.
- [x] C203 Mano inicial 4, máximo 8 y Descarte.
- [x] C204 Energía 1→6, recarga, límite extraordinario 12.
- [x] C205 Runa de Impulso del segundo jugador.
- [x] C206 Summoning sickness + Carga.
- [x] C207 Combate simultáneo + Emboscada + Blindaje + Guardia.
- [x] C208 Inestabilidad por mazo agotado.
- [x] C209 3 Sellos / 2 Reliquias con reemplazo.
- [x] C210 Recursos Instinto/Restos/Conocimiento/Calor.
- [x] C211 Sobrecarga de Calor.
- [x] C212 Pruebas headless del core.

## Fase CA — Clean Architecture
- [x] CA001 Formalizar reglas de dependencia Domain/Application/Infrastructure/Presentation.
- [x] CA002 Crear `CanonicalBattleSession` como fachada de casos de uso.
- [x] CA003 Crear `SaveRepositoryPort` en Application.
- [x] CA004 Crear `JsonSaveRepository` en Infrastructure con schema versionado.
- [x] CA005 Crear `DomainThemeRegistry` en Presentation.
- [x] CA006 Añadir guard automático de dependencias en CI.
- [x] CA007 Añadir tests de Application e Infrastructure.
- [ ] CA008 Migrar Battle UI desde `scripts/ui` a `scripts/presentation` usando únicamente Application.
- [ ] CA009 Migrar Main Menu a `scripts/presentation`.
- [ ] CA010 Migrar Campaña a Application + Presentation + Repository Port.
- [ ] CA011 Retirar `scripts/ui` cuando no tenga consumidores.

## Fase D — Efectos y dominios
- [ ] D301 Bosque: completar Manada e Instinto.
- [ ] D302 Cripta: Restos, Último Aliento y Exhumar.
- [ ] D303 Torre: Revelar, Eco y Canalizar.
- [ ] D304 Fundición: Constructos, Ensamblar, Sobrecalentar.
- [ ] D305 Guardianes iniciales.

## Fase E — UI canónica
- [x] E401 Adaptar Battle UI a la plantilla 4×2 canónica como prototipo legado.
- [x] E402 Skin Bosque prototipo v4.1.
- [ ] E403 Skin Cripta.
- [ ] E404 Skin Torre.
- [ ] E405 Skin Fundición.
- [x] E406 Finalizar turno abajo derecha.
- [x] E407 HUD único: Integridad, Energía, Esencia, Sellos, Reliquias, Mazo, Descarte.
- [ ] E408 Producir Bosque Asset Pack canónico bajo `assets/domains/forest/`.
- [ ] E409 Reemplazar dibujo procedural crítico por assets finales en Presentation.

## Fase F — Flujo principal
- [ ] F501 Splash cuatro dominios.
- [x] F502 Menú principal canónico prototipo.
- [ ] F503 Menú Jugar.
- [ ] F504 Elegir dominio.
- [x] F505 Vs CPU funcional como vertical slice.

## Fase G — Metajuego
- [ ] G601 Constructor de Mazos.
- [ ] G602 Colección y detalle de carta.
- [ ] G603 Perfil.
- [ ] G604 Logros.
- [ ] G605 Ajustes y Reducir movimiento.

## Fase H — Campaña
- [ ] H701 Crear expedición.
- [ ] H702 Mapa y rutas.
- [ ] H703 Evento.
- [ ] H704 Recompensa.
- [ ] H705 Mercader.
- [ ] H706 Altar de Sellos.
- [ ] H707 Fogata/Mejora.
- [ ] H708 Tesoro/Élite/Jefe.
- [ ] H709 Guardado/continuar mediante Repository Port.

## Fase I — Multiplayer
- [ ] I801 Local crear/unirse.
- [ ] I802 Lobby local.
- [ ] I803 Online rápida/clasificatoria/privada/amigos/historial.
- [ ] I804 Matchmaking.
- [ ] I805 Sincronización/validación mediante comandos/snapshots de Application.

## Fase J — Migración y Android
- [x] J901 Mantener firma Android y saves existentes durante el refactor actual.
- [ ] J902 Migrar runtime al Application layer canónico.
- [ ] J903 Retirar recursos/reglas legado ya no usados.
- [ ] J904 APK verde y validación visual en teléfono después de cada migración de pantalla.
