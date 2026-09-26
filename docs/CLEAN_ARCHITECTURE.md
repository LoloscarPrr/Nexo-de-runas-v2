# Nexo de Runas V2 — Clean Architecture pragmática

Este documento formaliza la arquitectura técnica para el Nexo canónico. No cambia reglas, mockups ni contenido: cambia cómo se organiza el código para que arte, UI, CPU, campaña, guardado y futuro multiplayer puedan evolucionar sin acoplarse entre sí.

## Regla de dependencias

Las dependencias apuntan hacia adentro:

```text
Presentation  ───────► Application ───────► Domain
Infrastructure ─────► Application Ports
```

### Domain — `scripts/domain/`
Responsable de reglas puras y estado jugable.

Incluye actualmente:
- catálogo canónico de cartas;
- BattleState;
- resolución de combate;
- recursos de dominio;
- CPU como servicio de reglas mientras dure la migración;
- campaña canónica cuando sea migrada.

Puede depender únicamente de otros módulos de `domain` y APIs base de Godot necesarias para estructuras de datos. No conoce escenas, botones, sprites, assets, red ni almacenamiento.

### Application — `scripts/application/`
Responsable de casos de uso y orquestación.

Ejemplos:
- iniciar batalla;
- jugar carta;
- finalizar ronda;
- inspeccionar unidad;
- crear mazo;
- iniciar expedición;
- comprar en mercader.

`CanonicalBattleSession` es la primera fachada de esta capa. Convierte el motor de dominio en snapshots/DTOs adecuados para presentación sin transferir responsabilidad de reglas a la UI.

`application/ports` contiene contratos que el exterior debe implementar, por ejemplo persistencia.

### Infrastructure — `scripts/infrastructure/`
Responsable de detalles externos:
- archivos de guardado;
- networking;
- Android;
- backend futuro;
- repositorios concretos.

Puede implementar puertos de Application. No decide reglas del juego ni composición visual.

El primer adapter es `JsonSaveRepository`, con envelope versionado para permitir migraciones futuras.

### Presentation — `scripts/presentation/`
Responsable únicamente de cómo se ve y se siente el juego:
- pantallas;
- cartas;
- HUD;
- themes de dominio;
- animaciones;
- shaders;
- audio y FX visuales.

Debe consumir Application y nunca importar Domain de forma directa.

`DomainThemeRegistry` fija desde ahora el contrato visual de los cuatro dominios y sus raíces de assets.

## Carpeta `scripts/ui/`

`scripts/ui/` es **código de compatibilidad durante la migración**. Contiene la batalla y campaña que ya exportan en Android. No se borra de golpe para no romper la APK, la firma ni saves.

Regla a partir de esta arquitectura:
- no introducir nueva lógica de negocio en `scripts/ui`;
- nuevas pantallas y el futuro renderer basado en assets se construyen en `scripts/presentation`;
- cada pantalla legado se retira cuando exista reemplazo funcional probado.

## Assets canónicos

La producción visual nueva se organizará así:

```text
assets/
├── common/
└── domains/
    ├── forest/
    │   ├── battle/
    │   ├── cards/
    │   ├── hud/
    │   ├── fx/
    │   └── menu/
    ├── crypt/
    ├── tower/
    └── forge/
```

La geometría de batalla permanece común. Los assets y Theme cambian por dominio.

## Flujo de una acción

Ejemplo de jugar una carta:

```text
Touch en CardView
       ↓
Presentation solicita PlayCard
       ↓
Application / CanonicalBattleSession
       ↓
Domain / BattleState resuelve reglas
       ↓
Application devuelve snapshot/resultado
       ↓
Presentation anima el resultado
```

La animación nunca determina si una jugada es legal.

## Multiplayer futuro

El mismo flujo permite que Local/Online envíen comandos serializables en vez de depender de nodos visuales. El servidor o peer autoritativo puede ejecutar los mismos casos de uso y comparar snapshots.

## Persistencia

Application conoce un `SaveRepositoryPort`; Infrastructure decide si ese repositorio usa JSON local, SQLite, nube u otra tecnología. La campaña y perfil no deben llamar `FileAccess` desde UI o Domain.

## Guard arquitectónico

`tests/clean_architecture_test.gd` revisa dependencias de los directorios nuevos en CI:
- Domain no puede depender de Application/Infrastructure/Presentation/UI.
- Application no puede depender de Infrastructure/Presentation/UI.
- Infrastructure no puede depender de Presentation/UI.
- Presentation no puede depender de Domain/Infrastructure/UI.

`scripts/ui` queda temporalmente fuera del guard hasta completar su migración.

## Estrategia de migración

1. Congelar reglas canónicas en Domain.
2. Introducir casos de uso en Application.
3. Encapsular persistencia/red en Infrastructure.
4. Construir el nuevo renderer de assets dentro de Presentation.
5. Reemplazar una pantalla legado a la vez.
6. Mantener tests + APK verde en cada paso.
7. Retirar `scripts/ui` sólo cuando ya no exista un consumidor activo.

## Principio práctico

Clean Architecture existe para permitir cambiar el arte, UI, persistencia o red sin reescribir las reglas. No se crearán interfaces o factories que no resuelvan una dependencia real.
