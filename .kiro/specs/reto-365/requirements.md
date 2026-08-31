# Requisitos — Reto 365

> Notación EARS. `DEBERÁ` = SHALL (obligatorio). Contexto de producto en
> [`PRD.md`](../../../PRD.md).

## Glosario

| Término | Definición |
|---|---|
| **Casilla** | Una de las 365 unidades del tablero. Su número (1..365) es el monto en MXN. |
| **Sortear** | Asignar al azar una casilla libre del tablero propio. |
| **Sorteo pendiente** | Sorteo ganado por el paso del tiempo y todavía no usado. |
| **Snapshot** | Estado completo de un tablero, codificado en un QR. |
| **`stateVersion`** | Contador monótono de mutaciones locales. Ordena los snapshots sin usar el reloj. |
| **Slot** | Identidad dentro del reto: A (`0`) o B (`1`). |
| **Pátina** | Desteñido progresivo de la tinta de la pareja según la antigüedad del último escaneo. |

---

## Requisito 1 — Emparejamiento

**Historia:** Como persona que empieza el reto, quiero emparejar mi app con la de
mi pareja cara a cara, para que cada quien pueda ver el avance del otro sin
internet.

#### Criterios de aceptación

1. CUANDO se abre la app sin emparejamiento ENTONCES el sistema DEBERÁ mostrar
   `/onboarding` con tres opciones: **Yo empiezo**, **Me uno al de mi pareja** y
   **Recuperar mi reto**.
2. CUANDO se elige **Yo empiezo** y se escribe un nombre ENTONCES el sistema
   DEBERÁ generar un `pairingId` aleatorio de 32 bits y un `installId` aleatorio
   de 64 bits, asignarse el slot A, fijar `startEpochDay` en el día local de hoy,
   sembrar 365 casillas en estado `free` y poner `stateVersion` en `0`, todo en
   una sola transacción.
3. CUANDO existe emparejamiento propio y se abre `/pair/show` ENTONCES el sistema
   DEBERÁ mostrar un QR con el payload `PAIR` definido en
   `docs/qr-sync-protocol.md` §5.1.
4. CUANDO se escanea un `PAIR` válido sin tener emparejamiento propio ENTONCES el
   sistema DEBERÁ adoptar el `pairingId` y el `startEpochDay` recibidos, tomar el
   slot contrario, guardar el nombre y el `installId` de quien invitó, generar su
   propio `installId` y sembrar sus 365 casillas.
5. CUANDO se escanea un `PAIR` válido teniendo ya emparejamiento propio y el
   `pairingId` coincide ENTONCES el sistema DEBERÁ guardar únicamente el nombre y
   el `installId` de la pareja, **sin tocar** las casillas propias.
6. SI el nombre de la pareja es `null` ENTONCES el sistema DEBERÁ mostrar de
   forma persistente *"Falta que escanees su código de respuesta"*.
7. CUANDO se escanea un `PAIR` con un `pairingId` distinto al propio ENTONCES el
   sistema DEBERÁ rechazarlo con *"Ese código no es de este reto"* y no escribir
   nada.
8. CUANDO se confirma **Restablecer el reto** dos veces en Ajustes ENTONCES el
   sistema DEBERÁ borrar las cuatro tablas y volver a `/onboarding`.
9. El nombre DEBERÁ aceptar entre 1 y 24 bytes UTF-8; el sistema DEBERÁ impedir
   guardar fuera de ese rango.

---

## Requisito 2 — Tablero propio

**Historia:** Como participante, quiero ver mis 365 casillas de un vistazo, para
saber qué llevo y qué me falta.

#### Criterios de aceptación

1. El sistema DEBERÁ mantener exactamente 365 filas en `OwnBoxes`, con `day` de 1
   a 365, durante toda la vida del reto.
2. CUANDO se abre `/board` ENTONCES el sistema DEBERÁ dibujar las 365 casillas en
   una cuadrícula perezosa de 12 columnas.
3. Cada casilla DEBERÁ distinguir su estado por **forma y relleno**, no solo por
   color, según `docs/design-system.md` §4.
4. Cada casilla DEBERÁ exponer un `Semantics` con día, monto y estado.
5. CUANDO se selecciona un filtro (Todas / Por pagar / Pagadas) ENTONCES el
   sistema DEBERÁ mostrar solo las casillas de ese estado sin recargar la
   pantalla.
6. SI el escalado de texto del sistema supera 1.3× ENTONCES la cuadrícula DEBERÁ
   bajar de 12 a 7 columnas.

---

## Requisito 3 — Sorteo

**Historia:** Como participante, quiero que la app me asigne un día al azar, para
que el reto no sea predecible y no me toquen los montos altos al final.

#### Criterios de aceptación

1. El sistema DEBERÁ calcular los sorteos pendientes como
   `pending = clamp((elapsed + 1), 0, 365) - drawn`, acotado a
   `[0, 365 - drawn]`, con `elapsed = todayEpochDay - startEpochDay`.
2. CUANDO `pending > 0` y quedan casillas libres ENTONCES el botón **Sortear**
   DEBERÁ estar activo y mostrar cuántos sorteos se deben.
3. CUANDO `pending == 0` ENTONCES el botón DEBERÁ estar inactivo con el texto
   *"Vuelve mañana por el tuyo"*.
4. CUANDO se toca **Sortear** ENTONCES el sistema DEBERÁ elegir uniformemente al
   azar entre las casillas `free`, ponerla en `assigned`, guardar
   `drawnAtMillis` y subir `stateVersion` en 1, **todo en la misma transacción**.
5. El sistema DEBERÁ deshabilitar el botón mientras la operación está en vuelo,
   de modo que dos toques rápidos no produzcan dos sorteos.
6. Una casilla `assigned` o `paid` **nunca** DEBERÁ volver a `free`.
7. SI el reloj del dispositivo retrocede y `elapsed` resulta negativo ENTONCES
   `pending` DEBERÁ ser `0`, nunca un número negativo.
8. CUANDO las 365 casillas están sorteadas ENTONCES el sistema DEBERÁ mostrar
   *"Terminaste los 365. $66,795."* y desactivar el sorteo para siempre.
9. La fuente de aleatoriedad DEBERÁ inyectarse por provider, para poder fijar la
   semilla en pruebas.

---

## Requisito 4 — Pagos

**Historia:** Como participante, quiero registrar cuándo aparté el dinero, para
distinguir lo que me tocó de lo que ya ahorré.

#### Criterios de aceptación

1. CUANDO se toca **Ya lo aparté** en una casilla `assigned` ENTONCES el sistema
   DEBERÁ ponerla en `paid`, guardar `paidAtMillis` y subir `stateVersion`.
2. CUANDO se mantiene presionada una casilla `paid` y se confirma ENTONCES el
   sistema DEBERÁ devolverla a `assigned`, limpiar `paidAtMillis` y subir
   `stateVersion`.
3. La pantalla de inicio DEBERÁ listar las casillas `assigned` ordenadas por
   `drawnAtMillis` ascendente, con el monto y cuánto hace que se sortearon.
4. SI no hay casillas `assigned` ENTONCES la sección DEBERÁ desaparecer, no
   mostrarse vacía.

---

## Requisito 5 — Progreso

**Historia:** Como participante, quiero ver cuánto llevo ahorrado, para sentir
que avanzo.

#### Criterios de aceptación

1. El sistema DEBERÁ calcular y mostrar: ahorrado (suma de `paid`), comprometido
   (suma de `assigned` + `paid`), pendiente de pago, restante contra 66,795,
   casillas hechas y día del reto.
2. Los montos DEBERÁN mostrarse en pesos enteros, con separador de miles, sin
   decimales y con cifras tabulares.
3. Toda la matemática del progreso DEBERÁ vivir en Domain, en Dart puro y sin
   dependencias de Flutter ni Drift.

---

## Requisito 6 — Generar QR de sincronización

**Historia:** Como participante, quiero mostrar un código con mi avance, para que
mi pareja me escanee.

#### Criterios de aceptación

1. CUANDO se abre `/sync/show` ENTONCES el sistema DEBERÁ mostrar un QR con el
   payload `SYNC` de `docs/qr-sync-protocol.md` §4.
2. El payload DEBERÁ medir exactamente 118 bytes y su texto base64url exactamente
   158 caracteres.
3. El QR DEBERÁ dibujarse en negro sobre superficie clara, con corrección de
   errores **M** y al menos 16 dp de zona de silencio, sin tinta de color.
4. CUANDO se muestra el QR ENTONCES el sistema DEBERÁ subir el brillo de la
   pantalla al máximo y restaurarlo al salir.
5. El payload DEBERÁ recalcularse **solo** cuando cambia `stateVersion`, nunca
   dentro de un `build`.

---

## Requisito 7 — Escanear y aplicar

**Historia:** Como participante, quiero escanear el código de mi pareja, para ver
su avance actualizado.

#### Criterios de aceptación

1. CUANDO se abre `/sync/scan` por primera vez ENTONCES el sistema DEBERÁ
   explicar para qué necesita la cámara **antes** de pedir el permiso.
2. SI se niega el permiso de cámara ENTONCES el sistema DEBERÁ mostrar cómo
   concederlo desde los ajustes del sistema, sin bloquear el resto de la app.
3. El sistema DEBERÁ validar todo payload escaneado en el orden exacto de
   `docs/qr-sync-protocol.md` §7 y **no escribir nada** si alguna comprobación
   falla.
4. CUANDO el snapshot se acepta ENTONCES el sistema DEBERÁ reemplazar las 365
   filas de `PartnerBoxes` y actualizar `PartnerSnapshots` **en una sola
   transacción**.
5. CUANDO se escanea un payload con `stateVersion` igual al guardado ENTONCES el
   sistema DEBERÁ no escribir nada y mostrar *"Ya estabas al día"* como
   resultado normal, **no como error**.
6. CUANDO se escanea un payload con `stateVersion` menor ENTONCES el sistema
   DEBERÁ rechazarlo con *"Ese código ya está viejo. Que vuelva a generarlo."*
7. CUANDO el `installId` entrante difiere del guardado ENTONCES el sistema DEBERÁ
   aceptar el snapshot sin importar su `stateVersion`, reiniciar la línea base y
   avisar que la pareja reinstaló la app.
8. CUANDO el `slot` entrante es igual al propio ENTONCES el sistema DEBERÁ
   responder *"Ese es tu propio código"*.
9. CUANDO el `schemaVersion` entrante no es `1` ENTONCES el sistema DEBERÁ
   responder *"Su app es de otra versión. Actualicen las dos."*
10. SI el `startEpochDay` entrante difiere del propio ENTONCES el sistema DEBERÁ
    aplicar el snapshot igualmente y dejar un aviso persistente en Ajustes.
11. CUANDO un escaneo se aplica ENTONCES el sistema DEBERÁ recordar mostrar el
    código propio para completar el ritual en la otra dirección.
12. Aplicar el mismo payload dos veces DEBERÁ dejar la base de datos idéntica.

---

## Requisito 8 — Ver a la pareja

**Historia:** Como participante, quiero ver el tablero de mi pareja y qué tan
viejos son esos datos, para saber si le voy ganando y si ya toca sincronizar.

#### Criterios de aceptación

1. El sistema DEBERÁ mostrar el progreso de la pareja calculado con **su**
   `startEpochDay`, no con el propio.
2. Todo dato de la pareja DEBERÁ ir acompañado de su antigüedad exacta en días,
   escrita en texto.
3. La tinta de la pareja DEBERÁ desteñirse según la tabla de pátina de
   `docs/design-system.md` §5, con piso de opacidad 0.35.
4. La opacidad de la pátina DEBERÁ aplicarse **solo a las tintas**, nunca al
   texto: la etiqueta de antigüedad se mantiene a contraste completo.
5. SI nunca se ha escaneado ENTONCES el sistema DEBERÁ mostrar *"Todavía no
   escaneas su código"* con acceso directo a `/sync/scan`.

---

## Requisito 9 — Ajustes

**Historia:** Como participante, quiero corregir nombres y entender qué pasa si
pierdo el teléfono.

#### Criterios de aceptación

1. El sistema DEBERÁ permitir editar los dos nombres sin romper el emparejamiento
   ni cambiar `stateVersion`.
2. El sistema DEBERÁ mostrar `pairingId`, fecha de inicio, slot propio y día
   actual del reto.
3. El sistema DEBERÁ explicar de forma visible que **el respaldo es el teléfono
   de la pareja**: si se pierde el propio, se recupera hasta la última
   sincronización y nada más; y que si la pareja nunca ha escaneado, no hay
   nada que recuperar.
4. **Restablecer el reto** DEBERÁ requerir dos confirmaciones y escribir en claro
   que se borra todo.

---

## Requisito 10 — Restricciones transversales

#### Criterios de aceptación

1. La app **nunca** DEBERÁ hacer una petición de red. No DEBERÁ existir ninguna
   dependencia de red, analítica o crash reporting en `pubspec.yaml`.
2. El único permiso declarado DEBERÁ ser `CAMERA`, y solo se pide al entrar a
   escanear.
3. Las tipografías DEBERÁN ir empaquetadas en `assets/fonts/`.
4. Los dos temas DEBERÁN cumplir contraste AA con los valores de
   `docs/design-system.md` §2.
5. Ningún widget DEBERÁ usar `BackdropFilter`, `BoxShadow` ni degradados.
6. Ningún widget DEBERÁ usar `Colors.*` ni `ColorScheme.fromSeed`: los colores
   salen de los tokens.
7. `flutter analyze` DEBERÁ terminar sin advertencias.
8. El feature `counter` de la plantilla DEBERÁ eliminarse por completo.

---

## Requisito 11 — Recuperación por QR (`RESTORE`)

**Historia:** Como persona que perdió o cambió de teléfono, quiero recuperar mi
tablero desde la app de mi pareja, para no perder un año de avance por no tener
servidor.

#### Criterios de aceptación

1. CUANDO existe un `PartnerSnapshots` guardado ENTONCES Ajustes DEBERÁ ofrecer
   **Ayudar a [Nombre] a recuperar su reto**.
2. SI nunca se ha escaneado a la pareja ENTONCES esa opción DEBERÁ estar
   inactiva y explicar que no hay nada guardado que devolver.
3. CUANDO se abre la pantalla de emisión ENTONCES el sistema DEBERÁ generar un
   QR `RESTORE` según `docs/qr-sync-protocol.md` §5.2, con el bitmap tomado de
   `PartnerBoxes`, el `restoredStateVersion` y el `snapshotEpochDay` tomados de
   `PartnerSnapshots`, y el nombre y el `installId` propios como emisor.
4. Emitir un `RESTORE` **no** DEBERÁ modificar ninguna tabla ni subir
   `stateVersion`.
5. CUANDO se elige **Recuperar mi reto** en `/onboarding` ENTONCES el sistema
   DEBERÁ pedir el nombre propio y abrir el escáner.
6. CUANDO se aplica un `RESTORE` válido sin configuración local ENTONCES el
   sistema DEBERÁ, **en una sola transacción**: crear `ChallengeConfigRows` con
   el `pairingId`, el slot contrario al del emisor, un `localInstallId`
   **nuevo**, el nombre escrito por la persona, el nombre y el `installId` del
   emisor, el `startEpochDay` recibido y `stateVersion = restoredStateVersion`;
   y sembrar las 365 `OwnBoxes` con los estados del bitmap y ambas fechas en
   `null`.
7. Aplicar un `RESTORE` **no** DEBERÁ escribir en `PartnerBoxes` ni en
   `PartnerSnapshots`: quedan vacías hasta que se escanee a la pareja.
8. SI ya existe `ChallengeConfigRows` ENTONCES el sistema DEBERÁ rechazar
   cualquier `RESTORE` con `RestoreNotApplicable` y el mensaje *"Ya tienes un
   reto en curso. Restablécelo primero si quieres recuperar otro."*, **sin
   escribir nada**.
9. El escaneo de `RESTORE` DEBERÁ ser inalcanzable desde `/sync/scan`: solo se
   llega desde `/onboarding`.
10. CUANDO la recuperación termina ENTONCES el sistema DEBERÁ mostrar
    *"Recuperaste lo que [Nombre] vio hace N días. Ahora escanea su código para
    volver a ver su avance."*, con N calculado desde `snapshotEpochDay`.
11. El sistema DEBERÁ tolerar casillas `assigned` o `paid` con `drawnAtMillis` en
    `null`: la lista de por pagar ordena por `day` como respaldo y la etiqueta
    de antigüedad degrada a *"sin fecha"*.
12. CUANDO llega un `SYNC` con `installId` distinto al guardado ENTONCES el
    mensaje DEBERÁ distinguir pérdida de recuperación: si el snapshot entrante
    trae **menos** casillas no libres que el guardado, *"[Nombre] reinstaló la
    app y perdió parte de su avance"* con enlace a ayudarle a recuperar; si trae
    las mismas o más, solo *"[Nombre] reinstaló la app"*.
