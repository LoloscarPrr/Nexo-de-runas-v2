# Assets canónicos por dominio

La producción visual nueva no debe quedar incrustada en scripts de reglas. Cada dominio comparte geometría e interacción, pero carga su propio lenguaje visual desde esta raíz.

Estructura objetivo por dominio:

```text
<domain>/
├── battle/   # fondo, mesa, marcos, carriles, Nexo y objetos de escena
├── cards/    # marcos, placas, rarezas e iconografía de carta
├── hud/      # Energía, Esencia, Sellos, Reliquias, Mazo, Descarte, botones
├── fx/       # partículas, glows, impactos, niebla, fuego, runas
└── menu/     # objetos y placas del menú/hub
```

IDs de dominio:
- `forest` — Bosque Salvaje
- `crypt` — Cripta de Hueso
- `tower` — Torre Arcana
- `forge` — Fundición Antigua

Los assets deben poder sustituirse sin modificar Domain ni Application. Presentation resuelve la raíz mediante `scripts/presentation/themes/domain_theme_registry.gd`.
