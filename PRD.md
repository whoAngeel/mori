# PRD — Mori · Reto 365 para dos

> **Estado:** aprobado para MVP · **Versión:** 1.0 · **Fecha:** 2026-08-31
> **Autor:** producto + arquitectura · **Ejecución:** Kiro (`.kiro/specs/reto-365/`)

---

## 1. Resumen

Mori es una app Flutter **offline-first, sin backend**, para que dos personas
lleven juntas el reto de ahorro de los 365 días.

Cada persona tiene **su propio tablero de 365 casillas**. El número de la casilla
es el monto a ahorrar en pesos mexicanos: la casilla 45 son $45 MXN. Completar
las 365 casillas equivale a **$66,795 MXN por persona** ($133,590 entre los dos).

Cada día se puede **sortear** una casilla libre al azar. La app no mueve dinero:
solo lleva el registro. La única forma de que cada quien vea el avance del otro
es **mostrar y escanear un código QR**.

### Por qué existe

Un reto de 365 días se abandona en la semana 3. Se abandona porque es solitario,
porque el orden secuencial lo vuelve predecible y porque a fin de año tocan puros
montos altos. El sorteo aleatorio resuelve lo segundo y lo tercero. La pareja
resuelve lo primero — pero solo si el avance del otro es **visible**. Ese es el
trabajo de la app.

### Qué NO es

- No es una app de finanzas. No se conecta a bancos, no calcula intereses, no
  guarda dinero. **Registra**, no administra.
- No tiene servidor, cuenta, login ni nube. Nunca.
- No es multiusuario. Son **dos personas, punto**.
- No es una app de recordatorios. Sin notificaciones push en el MVP.

---

## 2. Decisiones de producto (cerradas)

Estas decisiones ya se tomaron. Cambiar cualquiera de ellas invalida el diseño
técnico. Están en orden de impacto.

| # | Decisión | Consecuencia técnica |
|---|---|---|
| **D1** | **Cada persona tiene sus propios 365.** Los pools son independientes, no compartidos. | **No existe conflicto de asignación.** Cada dispositivo es autor único de su tablero. El QR replica un snapshot de *solo lectura*. Sin CRDT, sin vector clocks, sin resolución de conflictos. |
| **D2** | El número de casilla **es** el monto en MXN. | Sin campo `amount`: es una función del `day`. Total = 66,795. |
| **D3** | Un sorteo por persona por día natural; los días no jugados **se acumulan**. | `pendingDraws = (díasTranscurridos + 1) − casillasSorteadas`. No se guarda "último sorteo". |
| **D4** | El reloj del dispositivo **no es confiable y se acepta así**. Es una app para dos personas que confían entre sí. | No hay antitrampas. Pero el merge **no depende del reloj**: usa un contador monótono (`stateVersion`). |
| **D5** | Misma zona horaria. Sin lógica de TZ. | Se usa el día local del dispositivo (`epochDay`). |
| **D6** | El pago **se puede posponer**. Sortear no es pagar. | Tres estados: `free → assigned → paid`. |
| **D7** | Sortear **no se puede deshacer**. | La transición `assigned → free` no existe. Monotonicidad garantizada. |
| **D8** | El QR es **unidireccional** y eso se acepta. | Sincronizar completo = ritual de dos pasos, explícito en la UI. |
| **D9** | Payload de **estado completo**, siempre. Sin deltas. | 118 bytes. Cabe de sobra. Sin negociación de "¿desde qué punto?". |
| **D10** | **Sin historial** en el QR: solo el estado final. | Las fechas de sorteo/pago se guardan localmente para la propia UI, pero **no cruzan el QR**. |
| **D11** | Optimizado para **gama baja**. | Sin gzip (inútil en 118 B), sin criptografía, sin QR multi-frame. QR versión 8, cómodo de escanear. |
| **D12** | `schemaVersion` + `pairingId` + CRC32 en el payload. | Rechazo explícito y tipado de QR ajeno, corrupto o de otra versión. |
| **D13** | El merge es **idempotente**. Ninguna operación incrementa contadores. | Reescaneo del mismo QR = no-op silencioso, no error. |
| **D14** | Solo dos personas, para siempre. | `slot` de 1 bit. Snapshot de pareja = fila única. |
| **D15** | La desincronización **debe notarse**. | Es un elemento de diseño (la *pátina*, §6), no un banner de advertencia. |

### Decisiones que se delegaron a arquitectura (y aquí se resuelven)

| # | Pregunta abierta | Resolución |
|---|---|---|
| **D16** | ¿Cómo se estructura el merge en Drift? | Snapshot completo con reemplazo transaccional, guardado por `stateVersion` monótono. Detalle en [`docs/data-model.md`](docs/data-model.md). |
| **D17** | ¿Cómo se ordena sin reloj confiable? | Contador `stateVersion` (uint32) que sube +1 en cada mutación local. Se acepta el snapshot entrante solo si `incoming > stored`. |
| **D18** | ¿Qué pasa si alguien reinstala y pierde todo? | El payload lleva un `installId` aleatorio. Si cambia, el receptor sabe que hubo reinstalación y acepta el snapshot aunque su `stateVersion` haya vuelto a cero. Y como el otro teléfono ya guarda tu snapshot completo, **la pareja es tu respaldo**: el QR `RESTORE` es la puerta para sacarlo de ahí, y **está dentro del MVP** (§7). |
| **D20** | ¿Se puede recuperar el tablero tras perder el teléfono? | **Sí.** `RESTORE` (kind `0x03`) devuelve las 365 casillas desde el teléfono de la pareja. Vuelven los estados, el `pairingId`, el slot, la fecha de inicio y el nombre de la pareja; **no** vuelven las fechas de sorteo y pago, ni lo hecho después de la última sincronización. La app lo dice con esas palabras en lugar de fingir una recuperación completa. |
| **D19** | ¿Cómo se muestra la desincronización? | Pátina de tinta: el tablero de la pareja se "destiñe" por pasos conforme envejece el último escaneo. Detalle en [`docs/design-system.md`](docs/design-system.md). |

### Supuestos declarados (no se preguntaron, se asumen)

- **A1.** Marcar un pago **sí** se puede deshacer (`paid → assigned`). No contradice
  D7: lo irreversible es el sorteo, no el registro del pago. Un dedo gordo no
  debe costar un dato falso durante 365 días.
- **A2.** La fecha de inicio del reto se fija **una sola vez, en el emparejamiento**,
  y es la misma para los dos. Se transporta en el QR para poder detectar
  desacuerdos.
- **A3.** Los nombres son texto libre de máximo 24 bytes UTF-8, editables sin
  romper el emparejamiento.
- **A4.** Idioma: español mexicano. Sin i18n en el MVP.
- **A5.** Plataforma: **Android** (es la única configurada en el repo).

---

## 3. Usuarios y recorridos

Dos personas, mismo rol, mismos permisos. No hay administrador.

### Recorrido 1 — Emparejamiento (una sola vez)

Es una ceremonia de dos QR, cara a cara, y ocurre **una vez en la vida del reto**.

1. Persona A abre la app → *"Nadie ha empezado el reto"* → **Yo empiezo**.
2. A escribe su nombre. La app genera `pairingId`, se asigna el `slot A`, fija la
   fecha de inicio en hoy y siembra 365 casillas libres.
3. A muestra su **QR de emparejamiento**.
4. B abre la app → **Me uno al de mi pareja** → escanea el QR de A. B adopta el
   `pairingId` y la fecha de inicio, toma el `slot B` y siembra sus 365 casillas.
5. B muestra su **QR de respuesta**. A lo escanea para aprender el nombre y el
   `installId` de B.
6. Los dos ven el tablero. Emparejados.

> Si A escanea antes de que B se una, no pasa nada: el paso 5 es lo que cierra el
> círculo, y la app de A dice explícitamente *"Falta que escanees su código de
> respuesta"* hasta que ocurra.

### Recorrido 2 — El sorteo del día

1. Abrir la app. El botón principal dice **Sortear** y, debajo, cuántos sorteos
   se deben (`1 pendiente`, `3 pendientes` si se dejaron pasar días).
2. Tocar. La app elige uniformemente al azar entre las casillas libres.
3. Se revela la casilla sellada: **300 · $300 MXN**.
4. La casilla queda `assigned` y aparece en **Por pagar**.
5. Si hay más sorteos pendientes, el botón sigue activo.

### Recorrido 3 — Registrar el pago

1. En **Por pagar**, cada casilla tiene un botón **Ya lo aparté**.
2. Tocar lo pasa a `paid`. El total ahorrado sube.
3. Un toque largo sobre una casilla pagada permite **deshacer el pago** (A1).

### Recorrido 4 — Sincronizar (el ritual)

Es un intercambio presencial y explícito. La app nunca finge que se sincronizó sola.

1. Persona A entra a **Sincronizar** → **Mostrar mi código**.
2. B entra a **Sincronizar** → **Escanear**. Escanea a A.
3. B ve el tablero de A actualizado. La app le dice: *"Listo. Ahora muéstrale tu
   código para que se actualice."*
4. Se invierten los papeles. Terminado.

Resultados posibles al escanear, todos con mensaje propio:

| Resultado | Mensaje |
|---|---|
| Snapshot más nuevo aplicado | *"Actualizado. [Nombre] va en $X."* |
| Mismo snapshot que ya tenías | *"Ya estabas al día."* (no es un error) |
| Snapshot más viejo | *"Ese código ya está viejo. Que vuelva a generarlo."* |
| QR de otra pareja | *"Ese código no es de este reto."* |
| Tu propio QR | *"Ese es tu propio código."* |
| CRC inválido / recortado | *"No se pudo leer. Inténtalo otra vez."* |
| Versión de app distinta | *"Su app es de otra versión. Actualicen las dos."* |
| Fecha de inicio distinta | Se aplica, pero con aviso: *"Empezaron en fechas distintas."* |

### Recorrido 5 — Ver a la pareja

Pantalla de la pareja: su tablero de 365, su total, cuántas casillas debe, y
**qué tan viejos son esos datos**. Nunca se presenta un dato de la pareja sin su
fecha de impresión.

### Recorrido 6 — Recuperar el reto

A perdió el teléfono. Instala la app de nuevo y no tiene nada. B sí tiene
guardado el tablero de A, del último día que lo escaneó.

1. B entra a **Ajustes** → **Ayudar a Andrés a recuperar su reto**.
2. B muestra el QR `RESTORE`, que lleva el tablero de A tal como B lo tiene.
3. A abre la app recién instalada → **Recuperar mi reto** (la tercera opción de
   la pantalla inicial) → escanea.
4. A escribe su propio nombre — es lo único que no viaja en el código.
5. A recupera sus 365 casillas, el `pairingId`, su slot, la fecha de inicio y el
   nombre de B.
6. La app le dice la verdad: *"Recuperaste lo que Andrea vio hace 6 días. Ahora
   escanea su código para volver a ver su avance."*

Lo que **no** vuelve, y la app lo dice en lugar de disimularlo:

- Las fechas de sorteo y de pago. Las casillas recuperadas no tienen historia.
- Lo que A hizo después de la última vez que sincronizaron. Se perdió de verdad.
- La réplica del tablero de B. Hay que volver a escanearlo una vez.

> **Guarda:** un `RESTORE` solo se acepta si la app **no tiene ningún reto en
> curso**. Es la única operación capaz de sobrescribir el tablero propio, y esta
> regla hace imposible el accidente.

---

## 4. Requisitos funcionales

Los requisitos formales, en notación EARS y con criterios de aceptación, viven en
[`.kiro/specs/reto-365/requirements.md`](.kiro/specs/reto-365/requirements.md).
Resumen:

**RF-1 · Emparejamiento.** Crear reto, unirse por QR, responder por QR, mostrar
estado de emparejamiento incompleto, restablecer todo (con doble confirmación).

**RF-2 · Tablero propio.** 365 casillas con estado `free`/`assigned`/`paid`.
Vista de cuadrícula, filtros por estado, detalle de casilla.

**RF-3 · Sorteo.** Cálculo de sorteos pendientes con acumulación. Selección
uniforme entre libres. Deshabilitado cuando `pendingDraws == 0` o no quedan
libres. Irreversible.

**RF-4 · Pagos.** Marcar pagado, deshacer pago, lista de pendientes ordenada por
antigüedad de sorteo.

**RF-5 · Progreso.** Ahorrado, comprometido, restante, casillas hechas, día del
reto, y monto restante desglosado.

**RF-6 · Sincronización.** Generar QR de estado completo, escanear, validar,
aplicar de forma transaccional e idempotente, reportar resultado tipado.

**RF-7 · Vista de la pareja.** Tablero de la pareja, su progreso, y la frescura
del dato siempre visible.

**RF-8 · Ajustes.** Editar nombres, ver `pairingId` y fecha de inicio, explicar
que el respaldo es la pareja, restablecer el reto.

**RF-9 · Recuperación.** Emitir el QR `RESTORE` con el tablero guardado de la
pareja; escanearlo desde una instalación limpia; guarda que impide aplicarlo con
un reto en curso; comunicar con precisión qué se recuperó y qué no.

---

## 5. Requisitos no funcionales

| Área | Requisito |
|---|---|
| **Offline** | La app **nunca** hace una petición de red. Sin `http`, sin `dio`, sin fuentes remotas. Las tipografías van empaquetadas en `assets/`. |
| **Privacidad** | Nada sale del dispositivo salvo lo que aparece en un QR mostrado voluntariamente. Sin analítica, sin crash reporting, sin identificadores de publicidad. |
| **Permisos** | Solo `CAMERA`, y solo se pide al entrar a escanear. La primera vez se explica antes de pedirlo. |
| **Rendimiento** | La cuadrícula de 365 casillas usa `SliverGrid` con `itemBuilder` perezoso. Codificar o decodificar el payload debe tardar < 5 ms. El QR se genera una sola vez por estado, no en cada frame. |
| **Gama baja** | Sin blur, sin sombras costosas, sin `BackdropFilter`. Objetivo: 60 fps en un dispositivo de 2 GB de RAM. |
| **Integridad** | Todo escaneo se valida (magic, versión, CRC32, `pairingId`, `slot`) antes de tocar la base de datos. Aplicar un snapshot es una sola transacción Drift: se aplica completo o nada. |
| **Accesibilidad** | Contraste AA en ambos temas. El estado de una casilla **nunca** se codifica solo con color: hay diferencia de forma y etiqueta semántica. Objetivos táctiles ≥ 44 dp. Respeta el escalado de texto del sistema. |
| **Pruebas** | El códec y las reglas de merge tienen pruebas de propiedad (round-trip, idempotencia, monotonicidad) más vectores de oro. Drift se prueba con `NativeDatabase.memory()`. |
| **Documentación** | Todo tipo público lleva doc comment. `docs/` es la fuente de verdad del protocolo y el esquema; el código no lo re-explica, lo referencia. |

---

## 6. Dirección de diseño — «Dos tintas»

La dirección completa, con tokens, escalas y especificación de componentes, está
en [`docs/design-system.md`](docs/design-system.md). La tesis:

**El producto son dos personas que llevan el mismo reto por separado. El sistema
visual son dos tintas que nunca se mezclan.**

Se toma prestada la gramática de la **impresión risográfica**: dos tintas planas,
registro imperfecto, papel con cuerpo. Es un medio con exactamente la misma
restricción que el producto — dos capas independientes que solo se ven juntas
cuando alguien las superpone.

- **Cada persona tiene su tinta.** Tu tablero es rojo; el suyo es azul. Nunca
  aparecen mezcladas salvo en la vista de progreso conjunto, donde se
  superponen literalmente en multiply.
- **La casilla sellada** es el elemento firma: el bloque de tinta cae unos
  grados y unos píxeles fuera del contorno, como una risografía mal registrada.
  Es estático — no necesita animación para ser memorable.
- **La pátina** convierte D15 en diseño en lugar de advertencia: el panel de la
  pareja se destiñe por pasos conforme envejece el último escaneo, con su fecha
  de impresión escrita al pie. A los 14 días es un fantasma. No hay banner rojo
  de "desincronizado"; hay una hoja que se decoloró.

Tipografía: **Archivo** (display ancho y contundente) + **IBM Plex Mono**
(cifras tabulares — esta app es números, y los números merecen ancho fijo).
Ambas OFL, empaquetadas localmente.

---

## 7. Alcance del MVP

### Dentro

- Emparejamiento por QR (dos pasos) y restablecimiento.
- Tablero propio de 365 con los tres estados.
- Sorteo con acumulación de días.
- Registro y deshacer de pagos.
- Progreso propio.
- QR de sincronización: generar, escanear, validar, aplicar.
- **Recuperación por QR** (`RESTORE`): emitir el tablero guardado de la pareja
  para devolvérselo tras una reinstalación, y recuperar el propio.
- Tablero y progreso de la pareja con pátina de frescura.
- Ajustes: nombres, datos del reto, restablecer.
- Tema claro y oscuro.

### Fuera

- Notificaciones y recordatorios (explícitamente descartado).
- Animaciones. La UI es estática y bien compuesta; el movimiento llega en P1.
- Gráficas, rachas, logros, estadísticas comparativas.
- Exportar a CSV o compartir imágenes.
- iOS, web, escritorio.
- i18n.
- Cualquier cosa que toque la red.

---

## 8. Después del MVP

| Prio | Qué | Por qué |
|---|---|---|
| **P1** | Sello animado al sortear: el bloque de tinta cae y se asienta. Un solo momento, no efectos por todos lados. | El sorteo es el momento emocional del producto y hoy no tiene peso. |
| **P2** | Respaldo a archivo (exportar/importar JSON). | `RESTORE` cubre el caso normal, pero depende de que la pareja tenga un snapshot razonablemente fresco. Un archivo cubre el caso en que los dos teléfonos se pierden. |
| **P2** | Vista de progreso conjunto con superposición real de las dos tintas. | Es el pago emocional de toda la dirección visual. |
| **P3** | Notas por casilla ("de la quincena", "me lo prestó mi mamá"). | Solo si se pide. Rompe el presupuesto del QR. |

---

## 9. Métricas de éxito

No hay analítica, así que las métricas son cualitativas y se evalúan a mano:

1. **Los dos siguen usándola en el día 60.** Es la única métrica que importa.
2. Sincronizar no da flojera: pasa al menos una vez por semana sin que nadie
   tenga que insistir.
3. Nadie tiene que preguntarle al otro "¿ya pagaste el tuyo?" — la app ya lo dice.
4. Cero pérdidas de datos por un escaneo malo.

---

## 10. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Pérdida total de datos por reinstalación o cambio de teléfono | Alto | `RESTORE` recupera el tablero desde el teléfono de la pareja, y está en el MVP. `installId` detecta el caso y no bloquea la sincronización. Ajustes explica en claro que **el respaldo es la pareja**, y que solo se recupera hasta la última sincronización. |
| Se pierden los dos teléfonos, o la pareja nunca escaneó al otro | Medio | No hay recuperación posible. Ajustes lo dice sin adornos. Respaldo a archivo en P2. |
| El ritual de dos pasos se siente pesado y dejan de sincronizar | Medio | La pátina hace visible el costo de no sincronizar. La pantalla de sincronización dice explícitamente cuál es el siguiente paso. Ahora además hay un motivo duro: **sincronizar es respaldar**. |
| Escanear falla con poca luz en un teléfono viejo | Medio | QR versión 8 con corrección M, módulos grandes, zona de silencio amplia, brillo de pantalla al máximo mientras se muestra el código. |
| Ambos cambian de app y la versión del esquema diverge | Bajo | `schemaVersion` en el payload y mensaje explícito de "actualicen las dos". |
| El sorteo se siente injusto (salen puros montos altos al principio) | Bajo | Es aleatorio uniforme y así se explica. La posposición de pagos (D6) es la válvula de escape. |

---

## Documentos relacionados

| Documento | Contenido |
|---|---|
| [`docs/data-model.md`](docs/data-model.md) | Esquema Drift, invariantes, semántica del merge, matemática del progreso. |
| [`docs/qr-sync-protocol.md`](docs/qr-sync-protocol.md) | Formato binario byte por byte, codificación, validación, vectores de prueba. |
| [`docs/design-system.md`](docs/design-system.md) | Tokens, tipografía, componentes, pátina, accesibilidad. |
| [`.kiro/specs/reto-365/requirements.md`](.kiro/specs/reto-365/requirements.md) | Requisitos EARS con criterios de aceptación. |
| [`.kiro/specs/reto-365/design.md`](.kiro/specs/reto-365/design.md) | Diseño técnico por capas y por feature. |
| [`.kiro/specs/reto-365/tasks.md`](.kiro/specs/reto-365/tasks.md) | Plan de implementación incremental. |
