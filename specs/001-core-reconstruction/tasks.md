# Tasks 001 — Core canónico original

## Fase A — Rebasar fuente de verdad
- [x] A001 Constitución actualizada al juego original.
- [x] A002 Spec y plan actualizados al Documento Maestro Canónico v1.0.
- [x] A003 AGENTS actualizado para cuatro dominios y nuevo reglamento.
- [x] A004 Canon actualizado a Android vertical y exactamente 5 carriles por lado.

## Fase B — Core de datos
- [x] B101 Crear catálogo canónico de 48 cartas.
- [x] B102 Exponer 12 cartas por dominio y 4 mazos iniciales de 20.
- [x] B103 Validar IDs, tipos, costes, dominios y límites de copias.
- [x] B104 Mantener catálogo legado aislado durante migración.
- [x] B105 Introducir `CardDefinition` como modelo canónico tipado sobre el catálogo actual.
- [x] B106 Introducir `CardInstance` con identidad propia y estado mutable independiente.
- [ ] B107 Migrar campaña para que mejoras/sellos persistentes puedan dirigirse a copias concretas.

## Fase C — BattleState canónico
- [x] C201 Migrar de 4 a 5 carriles exactos por lado.
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
- [x] C213 Crear `BoardState` y `LaneState`; `BoardState` pasa a ser fuente de verdad para `LANE_COUNT=5`.
- [x] C214 Crear `CostDefinition`/`CostResolver` y conectar Energía/Esencia actuales.
- [x] C215 Crear `GameEvent`/`EventQueue` y emitir eventos lógicos básicos.

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
- [x] CA012 Crear `BattleCommand` y hacer que Application pueda ejecutar comandos serializables.
- [x] CA013 Incluir eventos de Domain en resultados de Application para Presentation/Local/Online.
- [x] CA014 Hacer que Application consulte `TargetSpec`/resolvers para objetivos de Rito, sin listas de IDs.

## Fase D — Efectos y dominios
- [x] D300 Introducir `AbilityDefinition`, `TargetSpec`, `ConditionDefinition`, `EffectDefinition` y resolvers.
- [ ] D301 Bosque: completar Manada e Instinto.
- [ ] D302 Cripta: completar Restos, Último Aliento y Exhumar.
- [ ] D303 Torre: completar Revelar, Eco y Canalizar.
- [ ] D304 Fundición: completar Constructos, Ensamblar y Sobrecalentar.
- [ ] D305 Guardianes iniciales.
- [x] D306 Extraer `match card_id` de Ritos, invocaciones y Último Aliento desde `CanonicalBattleState` hacia servicios declarativos.
- [x] D307 Migrar los Ritos y efectos ya implementados al catálogo declarativo de habilidades.
- [ ] D308 Migrar keywords estructurales de combate cuando corresponda: Emboscada, Guardia, Blindaje, Carga, etc.
- [ ] D309 Dar paridad de habilidades a CPU con recursos/controlador separados.
- [ ] D310 Introducir `AbilityInstance` para cargas/usos/cooldowns sólo cuando una mecánica real lo necesite.

## Fase E — UI canónica
- [x] E401 Adaptar Battle UI a una plantilla canónica como prototipo legado.
- [x] E402 Skin Bosque prototipo v4.1.
- [ ] E403 Skin Cripta.
- [ ] E404 Skin Torre.
- [ ] E405 Skin Fundición.
- [x] E406 Finalizar turno en zona inferior de acción.
- [x] E407 HUD único: Integridad, Energía, Esencia, Sellos, Reliquias, Mazo, Descarte.
- [ ] E408 Producir Bosque Asset Pack canónico bajo `assets/domains/forest/`.
- [ ] E409 Reemplazar dibujo procedural crítico por assets finales en Presentation.
- [x] E410 Ajustar adaptador legado para visualizar temporalmente los 5 carriles.
- [ ] E411 Crear renderer vertical de batalla en Presentation basado en mockup aprobado.
- [ ] E412 Resolver mano de 5–8 cartas con desplazamiento/solapamiento táctil legible.
- [ ] E413 Consumir `ABILITY_TRIGGERED`/`EFFECT_APPLIED` para animaciones sin lógica de reglas en Presentation.

## Fase F — Flujo principal
- [ ] F501 Splash cuatro dominios.
- [x] F502 Menú principal canónico prototipo.
- [ ] F503 Menú Jugar.
- [ ] F504 Elegir dominio.
- [x] F505 Vs CPU funcional como vertical slice legado.
- [ ] F506 Vs CPU vertical de cinco carriles conectado únicamente a Application.

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
- [ ] H710 Migrar modificaciones de campaña de `card_id` global a identidad de copia cuando corresponda.

## Fase I — Multiplayer
- [ ] I801 Local crear/unirse.
- [ ] I802 Lobby local.
- [ ] I803 Online rápida/clasificatoria/privada/amigos/historial.
- [ ] I804 Matchmaking.
- [ ] I805 Sincronización/validación mediante comandos/snapshots/eventos de Application.

## Fase J — Migración y Android
- [x] J901 Mantener firma Android y saves existentes durante el refactor actual.
- [ ] J902 Migrar runtime al Application layer canónico.
- [ ] J903 Retirar recursos/reglas legado ya no usados.
- [x] J904 APK verde y validación automatizada después de la migración inicial de cinco carriles.
- [ ] J905 Cambiar orientación runtime final a vertical sólo cuando Presentation vertical tenga equivalencia funcional.
