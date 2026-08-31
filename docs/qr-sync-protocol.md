# Protocolo de sincronización por QR

> **Versión del esquema: 1** · Fuente de verdad para cualquier implementación del
> códec. Si el código y este documento discrepan, el documento gana o el
> documento se actualiza — nunca se dejan divergir.

---

## 1. Principios

1. **Estado completo, siempre.** El payload describe el tablero entero. No hay
   deltas, ni negociación de punto de partida, ni "¿qué te falta?".
2. **Unidireccional.** Un escaneo actualiza a **una** persona. Sincronizar a las
   dos son dos escaneos. La UI lo dice, no lo esconde.
3. **Idempotente.** Aplicar el mismo payload N veces deja el mismo estado que
   aplicarlo una vez. Ninguna operación es "incrementa"; todas son "reemplaza".
4. **Monótono sin reloj.** El orden lo da un contador local (`stateVersion`), no
   una marca de tiempo. El reloj del sistema no participa en ninguna decisión de
   merge.
5. **Se valida antes de tocar la base.** Un payload inválido se rechaza con una
   razón tipada y no produce ninguna escritura.
6. **Barato.** 118 bytes, sin compresión, sin criptografía. Codificar y decodificar
   es aritmética de bytes.

---

## 2. Presupuesto

| | |
|---|---|
| Casillas | 365 |
| Bits por casilla | 2 |
| Bitmap | 730 bits → **92 bytes** |
| Payload `SYNC` completo | **118 bytes** |
| Base64url (sin padding) | **158 caracteres** |
| QR resultante | **versión 8, corrección M** (49 × 49 módulos) |

Cabe con muchísimo margen: el límite en modo byte de un QR versión 40 es 2,953
bytes. El tamaño elegido es el que se escanea bien en cámaras malas, no el
máximo posible.

> **Por qué base64url y no base45.** Base45 daría un QR versión 7 en lugar del 8
> — una diferencia de 4 módulos por lado. No justifica un códec escrito a mano.
> `dart:convert` ya trae base64url, y un payload que se puede pegar en un chat
> para depurar vale más que ese módulo de menos. Si el escaneo resulta poco
> confiable en campo, base45 es la primera optimización a probar.

---

## 3. Tipos de payload

| `kind` | Nombre | Cuándo | Tamaño |
|---|---|---|---|
| `0x01` | `SYNC` | Sincronización normal de estado | 118 B |
| `0x02` | `PAIR` | Emparejamiento (invitación y respuesta) | 23 + nombre (≤ 47 B) |
| `0x03` | `RESTORE` | Devolver a alguien su propio tablero tras reinstalar | 121 + nombre (122..145 B) |

Los tres se implementan en el MVP. Cualquier otro valor se rechaza con
`UnsupportedKind` en lugar de tratarse como basura.

`RESTORE` existe porque **no hay backend y por tanto no hay respaldo**: el único
lugar del mundo donde vive una copia de tu tablero es el teléfono de tu pareja,
en su tabla `PartnerBoxes`. `RESTORE` es la puerta para sacarla de ahí.

---

## 4. Formato binario — `SYNC` (kind `0x01`)

Todos los enteros son **big-endian, sin signo**.

```
offset  bytes  campo             notas
------  -----  ----------------  --------------------------------------------
   0      1    magic             siempre 0x4D ('M'). Rechazo rápido.
   1      1    schemaVersion     0x01
   2      1    kind              0x01 = SYNC
   3      4    pairingId         uint32 aleatorio, fijado al emparejar
   7      1    slot              0x00 = A, 0x01 = B (el emisor)
   8      8    installId         uint64 aleatorio, por instalación
  16      4    stateVersion      uint32, contador monótono del emisor
  20      2    startEpochDay     uint16, días desde 1970-01-01 (UTC)
  22     92    bitmap            365 casillas x 2 bits
 114      4    crc32             CRC-32/IEEE sobre los bytes 0..113
------  -----
        118    total
```

### 4.1 Bitmap

Estados:

| Valor | Estado | Significado |
|---|---|---|
| `0b00` | `free` | Casilla no sorteada |
| `0b01` | `assigned` | Sorteada, sin pagar |
| `0b10` | `paid` | Sorteada y pagada |
| `0b11` | — | Reservado. Al decodificar, **rechazar el payload completo** con `MalformedPayload`. |

Ubicación de la casilla `day` (1..365):

```
i     = day - 1                 // 0..364
byte  = 22 + (i >> 2)           // 4 casillas por byte
shift = (3 - (i & 3)) * 2       // primero el bit más significativo
valor = (bytes[byte] >> shift) & 0x03
```

Los 6 bits sobrantes del byte 113 (casillas 366..368, inexistentes) son
**relleno y deben ser cero**. Un decodificador estricto los verifica; si no son
cero, `MalformedPayload`.

### 4.2 `startEpochDay`

Días desde el 1 de enero de 1970 en UTC. `uint16` alcanza hasta el año 2149.

```dart
int toEpochDay(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;
```

Siempre se normaliza a medianoche UTC antes de convertir. La fecha *local* del
dispositivo se convierte primero a su fecha civil y luego a UTC medianoche —
nunca se usa `toUtc()` sobre un instante, porque eso desplaza el día.

### 4.3 CRC-32

CRC-32/IEEE 802.3, polinomio invertido `0xEDB88320`, valor inicial `0xFFFFFFFF`,
XOR final `0xFFFFFFFF`. Se implementa a mano — son ~20 líneas de Dart puro y
evita una dependencia.

```dart
// Tabla generada una vez, perezosamente.
int crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (final b in data) {
    crc = _table[(crc ^ b) & 0xFF] ^ (crc >> 8);
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
```

Cubre los bytes `0..113`. **No** se cubre a sí mismo.

> El CRC detecta corrupción, no manipulación. No es criptografía y no pretende
> serlo — es una app para dos personas que confían entre sí (decisión D4 del PRD).

---

## 5. Formatos binarios con nombre

### 5.1 `PAIR` (kind `0x02`)

```
offset  bytes  campo             notas
------  -----  ----------------  --------------------------------------------
   0      1    magic             0x4D
   1      1    schemaVersion     0x01
   2      1    kind              0x02
   3      4    pairingId         uint32
   7      1    slot              slot del emisor
   8      8    installId         uint64 del emisor
  16      2    startEpochDay     uint16
  18      1    nameLength        1..24
  19      N    name              UTF-8, N = nameLength
19+N      4    crc32             sobre los bytes 0..(18+N)
------  -----
      23+N     total (máx 47)
```

`PAIR` no lleva bitmap: al emparejar, los dos tableros están recién sembrados en
`free`.

El **mismo formato** sirve para la invitación y para la respuesta. Los distingue
el `slot`, no un campo aparte:

- **Invitación** (persona A): genera `pairingId`, se asigna `slot = 0`, fija
  `startEpochDay = hoy`.
- **Respuesta** (persona B): repite el `pairingId` y el `startEpochDay` recibidos,
  con `slot = 1` y su propio nombre e `installId`.

### 5.2 `RESTORE` (kind `0x03`)

Lo **emite quien no perdió nada**, para devolverle a la otra persona el tablero
que tiene guardado de ella en `PartnerBoxes`.

```
offset  bytes  campo                  notas
------  -----  ---------------------  ---------------------------------------
   0      1    magic                  0x4D
   1      1    schemaVersion          0x01
   2      1    kind                   0x03
   3      4    pairingId              uint32
   7      1    senderSlot             slot de QUIEN EMITE; el restaurado toma
                                      el contrario
   8      8    senderInstallId        uint64 del emisor
  16      4    restoredStateVersion   última stateVersion conocida del restaurado
  20      2    startEpochDay          uint16, fecha de inicio del reto
  22      2    snapshotEpochDay       uint16, día en que el emisor recibió
                                      este snapshot
  24     92    bitmap                 el tablero DEL RESTAURADO
 116      1    senderNameLen          1..24
 117      N    senderName             UTF-8, N = senderNameLen
117+N     4    crc32                  sobre los bytes 0..(116+N)
------  -----
      121+N    total (122 .. 145)
```

Base64url: 163 a 194 caracteres → **QR versión 9, corrección M** (53 × 53).

**No lleva el nombre del restaurado.** Se decidió que esa persona lo reescriba
durante la recuperación: se sabe su propio nombre, no hay riesgo de confusión, y
recortar el campo mantiene el QR una versión por debajo. El nombre que **sí**
viaja es el del emisor, porque ese es el que el restaurado no puede adivinar sin
riesgo de escribirlo distinto a como aparece en el otro teléfono.

**`snapshotEpochDay` es el campo honesto.** Con él, la app puede decir exactamente
*"Recuperaste lo que Andrea vio hace 6 días"*, en lugar de fingir que la
recuperación es completa. Lo que la persona hizo después de esa última
sincronización se perdió de verdad, y la app lo dice.

#### Qué se recupera y qué no

| Dato | ¿Vuelve? |
|---|---|
| Estado de las 365 casillas | **Sí** |
| `pairingId`, slot, `startEpochDay` | **Sí** |
| Nombre de la pareja | **Sí** |
| `stateVersion` | **Sí**, se adopta `restoredStateVersion` |
| Nombre propio | No — se reescribe |
| `drawnAtMillis` / `paidAtMillis` | **No.** Nunca cruzaron el QR (decisión D10). Quedan en `null`. |
| Réplica del tablero de la pareja | **No.** Hay que volver a escanear a la pareja una vez. |
| Lo hecho después de la última sincronización | **No.** Perdido de verdad. |

> Que las fechas queden en `null` **no es un caso de borde, es el estado normal
> tras una recuperación**. Toda la UI que muestra *"sorteado hace N días"* debe
> tolerar `null` y degradar a *"sin fecha"*, y la lista de por pagar debe ordenar
> por `day` cuando no hay `drawnAtMillis`. Es el error más probable de esta
> función.

---

## 6. Codificación de transporte

```
QR  ←  base64url sin padding  ←  bytes
```

- Alfabeto: `A–Z a–z 0–9 - _` (RFC 4648 §5). **Sin `=` de relleno.**
- `SYNC` → 158 caracteres. `PAIR` → 31..63 caracteres.
- Modo del QR: **byte**. Corrección de errores: **M**.

Dart:

```dart
String encode(Uint8List bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List decode(String text) =>
    base64Url.decode(text.padRight((text.length + 3) & ~3, '='));
```

Al decodificar, **antes** de nada: recortar espacios en blanco y comprobar que la
longitud es la esperada para el `kind`. Un QR truncado no debe llegar al CRC.

---

## 7. Validación al escanear

En este orden exacto. La primera que falla, corta.

| # | Comprobación | Fallo |
|---|---|---|
| 1 | El texto decodifica como base64url y la longitud es ≥ 19 | `MalformedPayload` |
| 2 | `magic == 0x4D` | `MalformedPayload` |
| 3 | `schemaVersion == 1` | `UnsupportedSchema` |
| 4 | `kind` ∈ {`0x01`, `0x02`, `0x03`} | `UnsupportedKind` |
| 5 | La longitud total coincide con la esperada para ese `kind` | `MalformedPayload` |
| 6 | `crc32` correcto | `ChecksumMismatch` |
| 7 | Ningún par de bits del bitmap vale `0b11`; el relleno es cero | `MalformedPayload` |
| 8 | `pairingId == config.pairingId` | `ForeignPairing` |
| 9 | `slot != config.localSlot` | `OwnPayloadScanned` |
| 10 | `installId` y `stateVersion` — ver §8 | `StaleSnapshot` (no-op) |

Las comprobaciones 8, 9 y 10 se omiten para un `PAIR` de invitación y para un
`RESTORE`, porque en ambos casos todavía no hay configuración local contra la
cual comparar. `RESTORE` tiene en su lugar una única guarda, mucho más
importante — ver §8.3.

---

## 8. Regla de aceptación del merge

Con el snapshot ya guardado de la pareja (`stored`) y el entrante (`incoming`):

```
si stored no existe:
    ACEPTAR                                        // primera sincronización

si incoming.installId != stored.installId:
    ACEPTAR y reiniciar la línea base               // reinstalación (ver 8.1)

si incoming.stateVersion >  stored.stateVersion:
    ACEPTAR

si incoming.stateVersion == stored.stateVersion:
    SIN CAMBIOS                                     // reescaneo — no es error

si incoming.stateVersion <  stored.stateVersion:
    RECHAZAR con StaleSnapshot                      // código viejo
```

Esta regla es **total, determinista y no consulta el reloj**. Es lo que hace que
la propiedad de idempotencia se cumpla por construcción: el segundo escaneo cae
en la rama `==`.

### 8.1 Reinstalación

`installId` es un `uint64` aleatorio que se genera **una vez por instalación** y
se guarda junto a la configuración. Si la pareja reinstala la app, su
`stateVersion` vuelve a empezar en cero y, sin este campo, sus QR quedarían
rechazados para siempre por la regla de monotonicidad.

Al detectar un `installId` distinto, el receptor acepta el snapshot y reinicia la
línea base. Es correcto aunque el snapshot venga vacío: **si la pareja perdió sus
datos, su tablero vacío es la verdad**.

El mensaje depende de cuánto trae el snapshot, no solo de que el `installId`
cambió — porque tras una recuperación con `RESTORE` el `installId` **también**
es nuevo, y decirle a alguien que su pareja "perdió su avance" justo después de
ayudarla a recuperarlo sería mentira:

```
sea entrantes = casillas no libres del snapshot entrante
sea guardadas = casillas no libres del snapshot guardado

si entrantes < guardadas:
    "[Nombre] reinstaló la app y perdió parte de su avance."
    + enlace a "Ayudarle a recuperar su reto"
si no:
    "[Nombre] reinstaló la app."
```

### 8.3 `RESTORE`: la guarda que importa

Aplicar un `RESTORE` **sobrescribe las 365 casillas propias**. Es la única
operación de la app que puede destruir datos, así que lleva una guarda dura:

> **Un `RESTORE` solo se acepta cuando no existe ninguna configuración local.**
> Si ya hay un reto en curso, se rechaza con `RestoreNotApplicable` y el mensaje
> *"Ya tienes un reto en curso. Restablécelo primero si quieres recuperar otro."*

Encaja exactamente con el caso real: una reinstalación deja la base vacía. Y
como efecto secundario, hace imposible el accidente de escanear un `RESTORE` y
perder un año de avance.

Refuerzo en la UI: el escaneo de `RESTORE` **solo** se alcanza desde la tercera
opción de `/onboarding`, **Recuperar mi reto**. No se llega desde `/sync/scan`.

Al aceptarlo, en una sola transacción:

```
crear ChallengeConfigRows con:
    pairingId          = payload.pairingId
    localSlot          = 1 - payload.senderSlot
    localInstallId     = uint64 aleatorio NUEVO   // es una instalación nueva
    localName          = el que escribió la persona
    partnerName        = payload.senderName
    partnerInstallId   = payload.senderInstallId
    startEpochDay      = payload.startEpochDay
    stateVersion       = payload.restoredStateVersion
sembrar las 365 OwnBoxes con los estados del bitmap,
    drawnAtMillis = null, paidAtMillis = null
NO tocar PartnerBoxes ni PartnerSnapshots (siguen vacías)
```

Se adopta `restoredStateVersion` en lugar de reiniciar en cero para que el
contador siga teniendo sentido. La pareja aceptará los siguientes `SYNC` por la
rama de `installId` distinto de §8.1 de todas formas.

La app cierra el flujo con la verdad y con el siguiente paso:
*"Recuperaste lo que [Nombre] vio hace N días. Ahora escanea su código para
volver a ver su avance."*, con N calculado desde `snapshotEpochDay`.

### 8.4 Fecha de inicio distinta

Si `incoming.startEpochDay != config.startEpochDay`, el snapshot **se aplica de
todas formas** pero se marca la discrepancia. La matemática del progreso de la
pareja se calcula con la fecha *de ella*, no con la propia. Se muestra un aviso
persistente en Ajustes hasta que se restablezca el reto.

---

## 9. Aplicación transaccional

Aceptar un snapshot es **una sola transacción Drift**. No hay estado intermedio
observable.

```
transaction {
  borrar todas las filas de PartnerBoxes
  insertar 365 filas de PartnerBoxes desde el bitmap
  upsert PartnerSnapshots con:
      stateVersion, installId, startEpochDay,
      receivedAtMillis = reloj local (solo para mostrar, nunca para decidir)
}
```

`receivedAtMillis` es el único lugar donde entra el reloj del sistema, y solo
alimenta la etiqueta *"impreso hace N días"* de la interfaz. Si el usuario mueve
el reloj, la etiqueta miente pero el merge no se rompe.

---

## 10. Generación

`stateVersion` sube **+1 en cada mutación local**, dentro de la misma transacción
que la mutación:

| Operación | ¿Sube `stateVersion`? |
|---|---|
| Sortear una casilla | Sí |
| Marcar pagado | Sí |
| Deshacer pago | Sí |
| Editar nombres | No (no viaja en `SYNC`) |
| Escanear a la pareja | No (no es una mutación propia) |
| Emitir un `RESTORE` para la pareja | No (es una lectura de `PartnerBoxes`) |
| Aplicar un `RESTORE` propio | No — se **adopta** `restoredStateVersion` tal cual |

Con un máximo de 365 sorteos y unos cuantos cambios de pago, `stateVersion` no
pasa de unos miles. Un `uint32` no se desborda nunca.

El QR se regenera solo cuando cambia `stateVersion`, no en cada frame.

---

## 11. Vectores de prueba

Estos vectores son **normativos**. Deben ir tal cual en `test/` como golden.

### V1 — Estado recién sembrado

```
pairingId     = 0x0BADC0DE
slot          = 0 (A)
installId     = 0x1122334455667788
stateVersion  = 0
startEpochDay = 20696        (2026-08-31)
bitmap        = 92 bytes en cero
```

Bytes 0..21 (cabecera):
```
4D 01 01 0B AD C0 DE 00 11 22 33 44 55 66 77 88
00 00 00 00 50 D8
```

CRC-32 = `0x927E8FF4` → bytes `92 7E 8F F4`

Texto completo del QR (158 caracteres):
```
TQEBC63A3gARIjNEVWZ3iAAAAABQ2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkn6P9A
```

### V2 — Casilla 1 asignada, casilla 365 pagada

Igual que V1 pero con `stateVersion = 2` y:

- `bitmap[0]`  = `0b01000000` = `0x40` — día 1 → `assigned` (i=0, byte=0, shift=6)
- `bitmap[91]` = `0b10000000` = `0x80` — día 365 → `paid` (i=364, byte=91, shift=6)

CRC-32 = `0x6EACD64A` → bytes `6E AC D6 4A`

Texto completo del QR (158 caracteres):
```
TQEBC63A3gARIjNEVWZ3iAAAAAJQ2EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAbqzWSg
```

> Ambos vectores se generaron y verificaron con CRC-32/IEEE (`zlib.crc32`). El
> día 365 cae en `bitmap[91]` con `shift = 6`, no `shift = 0`: el índice `i = 364`
> cumple `i & 3 == 0`, así que ocupa los **dos bits más significativos** del
> último byte. Es el error que más fácil se comete al implementar el bitmap.

### V3 — `RESTORE` de Andrea (slot B) hacia slot A

```
pairingId            = 0x0BADC0DE
senderSlot           = 1 (B)
senderInstallId      = 0x99AABBCCDDEEFF00
restoredStateVersion = 127
startEpochDay        = 20696        (2026-08-31)
snapshotEpochDay     = 20690        (2026-08-25, hace 6 días)
senderName           = "Andrea"     (6 bytes)
bitmap               : día 1 → paid, día 45 → assigned, día 365 → paid
```

Bytes 0..23 (cabecera):
```
4D 01 03 0B AD C0 DE 01 99 AA BB CC DD EE FF 00
00 00 00 7F 50 D8 50 D2
```

Bytes del bitmap distintos de cero: `[0] = 0x80`, `[11] = 0x40`, `[91] = 0x80`

CRC-32 = `0x3CFAB9BE` · total **127 bytes** · base64url **170 caracteres**

```
TQEDC63A3gGZqrvM3e7_AAAAAH9Q2FDSgAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAGQW5kcmVhPPq5vg
```

Cotas de tamaño verificadas: nombre de 1 byte → 122 bytes → 163 caracteres;
nombre de 24 bytes → 145 bytes → 194 caracteres. Ambas caben en un QR versión 9
con corrección M (capacidad 230).

### Propiedades que las pruebas deben verificar

| Propiedad | Enunciado |
|---|---|
| Round-trip | `decode(encode(s)) == s` para cualquier estado válido |
| Longitud | `encode(s).length == 158` para todo `SYNC` |
| Idempotencia | `apply(apply(db, p), p) == apply(db, p)` |
| Monotonicidad | Aplicar un `p` con menor `stateVersion` nunca modifica la base |
| Detección de corrupción | Voltear cualquier bit invalida el CRC |
| Cobertura de casillas | Los 365 días recorren los 92 bytes sin colisión ni hueco |
| Relleno | Los 6 bits finales siempre son cero |
| Longitud variable | `RESTORE` decodifica correctamente con nombres de 1 y de 24 bytes, y con nombres que llevan emoji (multibyte) |
| Guarda de `RESTORE` | Con configuración local presente, aplicar un `RESTORE` **no escribe nada** y devuelve `RestoreNotApplicable` |
| Fechas tras recuperar | Todas las casillas restauradas quedan con `drawnAtMillis` y `paidAtMillis` en `null`, y la UI las tolera |
