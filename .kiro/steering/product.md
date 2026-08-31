---
inclusion: always
---

# Producto — Mori

App Flutter **offline-first, sin backend**, para que **dos personas** lleven
juntas el reto de ahorro de los 365 días.

## Reglas de negocio que nunca se negocian

1. **Cada persona tiene sus propios 365.** Los tableros son independientes. Dos
   personas pueden sacar el mismo día y no es un conflicto: son casillas
   distintas en tableros distintos.
2. **El número de casilla es el monto en MXN.** Casilla 45 = $45. Total por
   persona = **$66,795**.
3. **Un sorteo por persona por día natural**, y los días no jugados **se
   acumulan**.
4. **Sortear es irreversible.** `assigned` nunca vuelve a `free`.
5. **Sortear no es pagar.** El pago se pospone y se registra aparte. Marcar un
   pago sí se puede deshacer.
6. **La app no mueve dinero.** Registra. No se conecta a bancos ni calcula nada
   financiero.
7. **Cero red.** Nunca. Ni fuentes remotas, ni analítica, ni crash reporting.
8. **La única sincronización es por QR**, presencial, y es **unidireccional**:
   un escaneo actualiza a una persona. Sincronizar a las dos son dos escaneos, y
   la UI lo dice en voz alta.
9. **El merge es idempotente.** Reescanear el mismo código no es un error: es
   *"ya estabas al día"*.
10. **La desincronización se nota.** Es parte del diseño, no una advertencia.
11. **El respaldo es la pareja.** No hay servidor, así que la única copia de tu
    tablero vive en el teléfono del otro. El QR `RESTORE` la devuelve. Solo se
    acepta en una app **sin reto en curso** — es la única operación capaz de
    destruir datos propios, y esa guarda vive en el repositorio, no en la UI.
12. **La app dice la verdad sobre lo que se recuperó.** Tras un `RESTORE` no
    vuelven las fechas de sorteo ni lo hecho después de la última
    sincronización, y la app lo dice con esas palabras.

## Fuera de alcance del MVP

Notificaciones, animaciones, gráficas, rachas, logros, exportar, iOS, web, i18n,
y absolutamente cualquier cosa que toque la red.

## Voz

Español mexicano, tuteo, directo. Los errores no piden perdón y nunca son vagos.
Los botones dicen exactamente qué pasa al tocarlos. Ver §8 de
`docs/design-system.md` para la tabla de copy.

## Documento maestro

`PRD.md` en la raíz. Si algo aquí contradice al PRD, gana el PRD.
