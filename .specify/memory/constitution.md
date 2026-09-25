# Constitución — Nexo de Runas V2

## I. Identidad original como única dirección activa
Nexo de Runas es un juego original de cartas tácticas por carriles. La etapa anterior centrada en replicar el Acto 1 de Inscryption queda archivada. Sus implementaciones pueden conservarse durante la migración, pero no definen nuevas reglas, contenido ni UI.

## II. Canon visual
La referencia visual son los mockups canónicos aprobados y el Documento Maestro Canónico v1.0: fantasía oscura premium, materiales físicos, runas, ornamentación, profundidad e iluminación cinematográfica. Los cuatro dominios comparten una arquitectura visual común y cambian únicamente ambientación, materiales, paleta, iconografía y efectos temáticos.

## III. Cuatro dominios
Los dominios activos son:
- Bosque Salvaje — Instinto.
- Cripta de Hueso — Restos.
- Torre Arcana — Conocimiento.
- Fundición Antigua — Calor.
Cada dominio debe tener identidad mecánica propia sin alterar el layout fundamental del juego.

## IV. Núcleo de batalla
- Exactamente 4 carriles por jugador.
- 20 de Integridad del Nexo.
- Mazo de 20 cartas + 1 Guardián externo.
- Mano inicial de 4 y máximo de 8.
- Energía Rúnica progresiva 1→6, recargada al inicio del turno.
- 6 es máximo estándar; 12 es límite absoluto mediante efectos extraordinarios.
- Máximo 3 Sellos y 2 Reliquias activas.
- Cartas: Criatura, Rito, Reliquia y Sello.

## V. Modos y metajuego
El flujo objetivo contempla Campaña, Vs CPU, Jugar Local y Jugar Online. El menú principal también contiene Constructor de Mazos, Colección, Perfil, Logros y Ajustes. El multiplayer se implementa después de estabilizar el core de batalla y la campaña, pero forma parte del diseño canónico.

## VI. Reglas separadas de presentación
Estado, cartas, mazos, recursos, turnos, efectos, campaña y progreso viven separados de la UI. El mismo core debe poder alimentar CPU, guardado, local y online.

## VII. Interacción móvil
Objetivo primario: Android horizontal 1280×720 de referencia, escalado responsivo y touch-first. Ninguna acción esencial puede depender de hover. La UI debe ser legible con el pulgar y conservar el tablero como foco.

## VIII. Persistencia y compatibilidad
La firma Android persistente y los saves existentes no deben romperse durante la migración. Los nuevos datos deben ser versionables y migrables.

## IX. Build verde como contrato
Todo cambio en main debe mantener proyecto importable y APK Android exportable. La migración desde el core legado se hace por unidades coherentes y probadas.

## X. Spec antes de implementación grande
Todo cambio relevante se refleja en Constitución → Spec → Plan → Tasks → Implementación → Verificación.

## Criterio de convergencia
Una fase se cierra cuando sus reglas canónicas están implementadas, cubiertas por pruebas, observables en Android y el APK exporta en CI sin reintroducir reglas antiguas como autoridad del nuevo diseño.
