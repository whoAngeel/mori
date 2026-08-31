# Sistema de diseño — «Dos tintas»

> Dirección visual, tokens y especificación de componentes. Es normativo: si un
> widget necesita un color, sale de aquí, no de `Colors.*` ni de un
> `ColorScheme.fromSeed`.

---

## 1. La tesis

**El producto son dos personas que llevan el mismo reto por separado. El sistema
visual son dos tintas que nunca se mezclan.**

La gramática viene de la **impresión risográfica**: dos tintas planas, registro
imperfecto, papel con cuerpo. Se eligió porque es un medio con exactamente la
misma restricción que el producto — dos capas independientes que solo se ven
juntas cuando alguien las superpone físicamente. Un tablero de 365 casillas ya es
una plancha impresa; solo había que admitirlo.

Tres reglas que se siguen sin excepción:

1. **Cada persona tiene su tinta.** Tu tablero es rojo. El suyo es azul. No hay
   una tercera tinta para "el sistema".
2. **La tinta se imprime, no se ilumina.** Bloques planos, sin degradados, sin
   sombras, sin brillos, sin blur. Un `BoxShadow` en esta app es un bug de
   diseño. (También es lo correcto para gama baja.)
3. **El registro es imperfecto a propósito.** El bloque de tinta cae unos píxeles
   fuera de su contorno. Es lo que hace que la app no se parezca a un
   `ColorScheme.fromSeed` más.

### Lo que se descartó, y por qué

- **Fondo crema + serif de alto contraste + acento terracota.** Es el aspecto por
  defecto que sale de cualquier prompt de "app bonita" ahora mismo. El papel aquí
  es gris-verdoso frío (`#E8E9E3`), no crema, y no hay ni una serif.
- **Negro con un acento verde ácido.** Igual de genérico y peor para leer 365
  números pequeños.
- **Textura de semitono.** Era la opción más obvia para "hacerlo más riso" y era
  justo el accesorio de más: cuesta rendimiento en gama baja y no se ve a 4 mm
  por casilla. Fuera. La firma se sostiene con el desfase de registro sola.
- **Marcadores numerados 01 / 02 / 03.** No hay ninguna secuencia real que
  comunicar. Lo único numerado en esta app son los días, y esos ya son el
  contenido.

---

## 2. Tokens de color

Todos verificados contra WCAG. La razón de contraste está anotada porque estos
valores no se cambian "a ojo": si se tocan, se recalculan.

### Tema claro

| Token | Hex | Uso | Contraste |
|---|---|---|---|
| `paper` | `#E8E9E3` | Fondo de la app | — |
| `plate` | `#F5F5F0` | Superficies elevadas (tarjetas, hojas) | — |
| `inkBlack` | `#1A1A1E` | Todo el texto. Negro de imprenta, no `#000`. | 14.2 : 1 sobre papel |
| `inkMuted` | `#66665F` | Texto secundario, números de casillas libres | 4.74 : 1 |
| `inkSelf` | `#B3243F` | **Tinta A — tú.** Rellenos y cifras grandes. | 5.31 : 1 · texto papel encima 5.31 : 1 |
| `inkPartner` | `#005E96` | **Tinta B — tu pareja.** | 5.65 : 1 · texto papel encima 5.65 : 1 |
| `overprint` | `#47265E` | Solo en la vista conjunta, donde las dos tintas se superponen. | 9.9 : 1 |
| `rule` | `#C8C9C1` | Filetes y separadores de 1 dp | — |

### Tema oscuro

| Token | Hex | Contraste sobre `paper` |
|---|---|---|
| `paper` | `#151518` | — |
| `plate` | `#1E1E22` | — |
| `inkBlack` | `#E8E8E2` | 14.8 : 1 |
| `inkMuted` | `#9A9A93` | 6.44 : 1 |
| `inkSelf` | `#FF6B78` | 6.62 : 1 |
| `inkPartner` | `#3FA3E0` | 6.53 : 1 |
| `overprint` | `#B79BD6` | 8.1 : 1 |
| `rule` | `#33333A` | — |

> **El `overprint` no es el multiply literal.** `#B3243F × #005E96` da casi negro
> (`#000D25`), que en papel real no pasa porque las tintas riso son
> translúcidas. El token es un ciruela elegido a mano que sí lee como "las dos
> tintas encimadas". Si se implementa la superposición con
> `BlendMode.multiply`, hay que subir la luminosidad de las capas primero.

### Regla de uso de las tintas

Las tintas son para **rellenos, filetes gruesos y cifras grandes**. El texto
corrido va siempre en `inkBlack`. No porque no contrasten —contrastan— sino
porque una app de dos tintas donde todo está teñido deja de tener dos tintas.

---

## 3. Tipografía

Dos familias. Las dos con licencia OFL y **empaquetadas en `assets/fonts/`** —
nada de `google_fonts`, que descarga en tiempo de ejecución y esta app no toca la
red jamás.

| Rol | Familia | Por qué |
|---|---|---|
| Display y texto | **Archivo** | Grotesca ancha, de cartel, con formas contundentes. Aguanta pesos altos sin volverse decorativa y tiene el aire impreso que pide la dirección. |
| Cifras | **IBM Plex Mono** | Esta app es números: montos, días, totales. Cifras tabulares que alinean en una cuadrícula de 365 celdas y en una columna de montos. |

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Archivo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Archivo-ExtraBold.ttf
          weight: 800
    - family: PlexMono
      fonts:
        - asset: assets/fonts/IBMPlexMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/IBMPlexMono-SemiBold.ttf
          weight: 600
```

### Escala

| Estilo M3 | Familia | Tamaño / interlínea | Peso | Tracking | Uso |
|---|---|---|---|---|---|
| `displayLarge` | PlexMono | 44 / 44 | 600 | −1.0 | El monto ahorrado |
| `displaySmall` | PlexMono | 28 / 30 | 600 | −0.5 | Montos secundarios |
| `headlineMedium` | Archivo | 24 / 28 | 800 | −0.4 | Títulos de pantalla |
| `titleMedium` | Archivo | 16 / 20 | 600 | 0 | Encabezados de sección |
| `bodyMedium` | Archivo | 15 / 22 | 400 | 0 | Texto corrido |
| `labelLarge` | Archivo | 14 / 16 | 600 | +0.2 | Botones |
| `labelSmall` | Archivo | 11 / 12 | 600 | +1.2 | Antetítulos, **en versalitas** |
| `numeric` | PlexMono | 13 / 14 | 400 | 0 | Números dentro de las casillas |

Los antetítulos van en mayúsculas **y** con tracking. Uno sin el otro se ve como
un accidente.

---

## 4. La firma — la casilla sellada

Es el elemento por el que se recuerda la app, y es **estático**: no necesita
animación para funcionar (el MVP no la lleva; el sello animado es P1).

Una casilla es una pila de dos capas mal registradas:

```
   ┌───────────┐        contorno: 1.5 dp, inkBlack, radio 2
   │ ▓▓▓▓▓▓▓▓▓ │◄──┐    bloque de tinta desplazado 2 dp
   │ ▓▓ 300 ▓▓ │   │    el número queda en color papel (knockout)
   │ ▓▓▓▓▓▓▓▓▓ │   │
   └──▓▓▓▓▓▓▓▓▓┘◄──┘    el desfase se ve arriba-derecha y abajo-izquierda
```

El desplazamiento es **determinista por día**, no aleatorio: la misma casilla se
imprime siempre igual, y el tablero completo muestra una variación sutil como una
plancha real.

```dart
Offset misregistration(int day) => Offset(
      ((day * 37) % 5) - 2.0,   // -2..+2 dp
      ((day * 53) % 5) - 2.0,
    );
```

### Los tres estados

Se distinguen por **forma y relleno**, no solo por color — requisito de
accesibilidad, y además es lo que hace legible un tablero de 365 celdas de un
vistazo.

| Estado | Contorno | Bloque de tinta | Número |
|---|---|---|---|
| `free` | 1 dp `rule` | ninguno | `inkMuted`, peso 400 |
| `assigned` | 1.5 dp `inkBlack` | **perfilado**, 2 dp de tinta, desfasado | tinta, peso 600 |
| `paid` | 1.5 dp `inkBlack` | **sólido**, desfasado | color papel (knockout), peso 600 |

Léelo como una imprenta: sin imprimir → media tinta → tinta completa.

---

## 5. La pátina — la desincronización como material

El PRD exige que la desincronización se note (D15). No con un banner rojo: con
una hoja que se decoloró.

El panel y el tablero de la pareja pierden tinta por pasos conforme envejece el
último escaneo:

| Días desde el último escaneo | Opacidad de la tinta | Etiqueta |
|---|---|---|
| 0–2 | 1.00 | *Impreso hoy* / *Impreso hace 2 días* |
| 3–6 | 0.72 | *Impreso hace 5 días* |
| 7–13 | 0.52 | *Impreso hace 9 días* |
| 14 o más | 0.35 | *Impreso hace 21 días* · **Sincronizar** |
| Nunca | — | *Todavía no escaneas su código* |

**La opacidad se aplica solo a las tintas**, nunca al texto. Todo el texto del
panel —incluida la etiqueta con el número exacto de días— se mantiene en
`inkBlack` a contraste completo. La pátina es una señal **redundante**: quien no
la perciba lee la fecha, que siempre está escrita. El piso de 0.35 existe para
que un tablero viejo siga siendo legible, no decorativo.

---

## 6. Disposición

Rejilla de 4 dp. Margen lateral de 20 dp. Ancho máximo de contenido 480 dp
(la app se ve bien en una tablet sin estirarse).

### Inicio

```
┌──────────────────────────────────────┐
│ RETO 365 · DÍA 128            ⚙      │  labelSmall + ajustes
│                                      │
│  $8,240                              │  displayLarge, PlexMono, inkSelf
│  de $66,795 · 92 casillas            │  bodyMedium, inkMuted
│  ████████████░░░░░░░░░░░░░░░░░░░     │  barra 6 dp, inkSelf sobre rule
│                                      │
│  ┌────────────────────────────────┐  │
│  │  SORTEAR                       │  │  bloque inkSelf, texto papel
│  │  2 sorteos pendientes          │  │  altura 72 dp
│  └────────────────────────────────┘  │
│                                      │
│  POR PAGAR · 3                       │  labelSmall
│  ┌──┐                                │
│  │45│  $45     sorteado hace 3 días  │  casilla + monto mono
│  └──┘                     Ya lo aparté│
│  ┌───┐                               │
│  │300│ $300    sorteado ayer         │
│  └───┘                    Ya lo aparté│
│                                      │
│  ─────────────────────────────────   │  filete
│                                      │
│  ANDREA · IMPRESO HACE 8 DÍAS        │  labelSmall, inkBlack
│  $7,110 · 121 casillas               │  tinta B al 52 %
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░     │
│  [ Sincronizar ]                     │
└──────────────────────────────────────┘
```

La decisión de fondo: **el botón de sortear es lo más grande de la pantalla
después del monto**. Es la acción del día y no compite con nada.

### Tablero

```
┌──────────────────────────────────────┐
│ MI TABLERO                           │
│ [ Todas ] [ Por pagar ] [ Pagadas ]  │  filtros, filete inferior activo
│                                      │
│  1  2  3  4  5  6  7  8  9 10 11 12  │  12 columnas, casilla 24 dp
│ 13 ▓▓ 15 16 ▓▓ 18 19 20 21 22 23 24  │
│ 25 26 27 ▓▓ 29 30 31 32 33 34 35 36  │
│  …                                   │
│                                      │
│ ├──────┼──────┼──────┼──────┼──────┤ │  la regla de 365 marcas
│ ENE   MAR    MAY    JUL    SEP   DIC │
└──────────────────────────────────────┘
```

12 columnas × 31 filas cubre los 365 con un remanente natural. `SliverGrid` con
constructor perezoso: nunca se construyen 365 widgets a la vez.

La **regla al pie** —365 marcas de 1 dp, teñidas las hechas— es el segundo lugar
donde el número 365 se vuelve algo que se ve en lugar de leerse. Solo aparece
aquí, no en Inicio: repetirla la abarataría.

### Sincronizar

```
┌──────────────────────────────────────┐
│ SINCRONIZAR                          │
│                                      │
│ Se hacen dos escaneos: uno para que   │
│ ella te vea, otro para que tú la veas.│
│                                      │
│ ┌──────────────────────────────────┐ │
│ │  1  MOSTRAR MI CÓDIGO            │ │
│ │     Para que ella te escanee      │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │  2  ESCANEAR EL SUYO             │ │
│ │     Última vez: hace 8 días       │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

Aquí **sí** van los números 1 y 2: es una secuencia real, con orden que importa,
y es justo lo que la gente olvida del ritual.

Al mostrar el código, la pantalla sube el brillo al máximo y el QR se dibuja
sobre `plate` puro con 16 dp de zona de silencio. El QR no lleva tinta: negro
sobre blanco es lo que escanean las cámaras malas.

---

## 7. Componentes

| Componente | Definición |
|---|---|
| `InkBox` | La casilla sellada. Parámetros: `day`, `status`, `ink`, `size`, `opacity`. Es el widget más usado de la app y el que más merece un test de golden. |
| `InkButton` | Bloque de tinta sólido, radio 2, texto en color papel, altura 56 dp (72 dp el primario). Al presionar: el bloque se mueve a registro perfecto (desfase 0). Sin ripple — `splashFactory: NoSplash`, no encaja con la imprenta. |
| `GhostButton` | Contorno de 1.5 dp `inkBlack`, sin relleno. Acciones secundarias. |
| `Eyebrow` | `labelSmall` en versalitas con tracking. Encabeza cada sección. |
| `Amount` | Monto en PlexMono con `FontFeature.tabularFigures()` y separador de miles. Siempre con `$` y sin decimales: son pesos enteros. |
| `PatinaPanel` | Envoltura que aplica la opacidad de §5 a sus tintas y estampa la etiqueta de impresión al pie. |
| `RuleOf365` | Las 365 marcas del pie del tablero. |
| `EmptyPlate` | Estado vacío: contorno punteado y una frase que invita a actuar, nunca un dibujito. |

---

## 8. Redacción

La voz es la de una imprenta: directa, concreta, sin adornos. Español mexicano,
tuteo, mayúscula solo al inicio de la frase.

| Contexto | Sí | No |
|---|---|---|
| Botón de sorteo | **Sortear** | "¡Descubre tu día!" |
| Marcar pago | **Ya lo aparté** | "Confirmar transacción" |
| Sin sorteos | **Vuelve mañana por el tuyo** | "No hay sorteos disponibles" |
| Tablero lleno | **Terminaste los 365. $66,795.** | "¡Felicidades, lo lograste!" |
| Escaneo repetido | **Ya estabas al día** | "Error: sin cambios" |
| QR ajeno | **Ese código no es de este reto** | "Payload inválido" |
| QR ilegible | **No se pudo leer. Inténtalo otra vez.** | "Perdón, ocurrió un error" |
| Sin sincronizar | **Todavía no escaneas su código** | "Sin datos" |
| Emparejar | **Yo empiezo** / **Me uno al de mi pareja** | "Crear sesión" / "Unirse" |
| Recuperar (entrada) | **Recuperar mi reto** | "Importar backup" |
| Ayudar a recuperar | **Ayudar a Andrea a recuperar su reto** | "Exportar datos del peer" |
| Nada que devolver | **Todavía no has escaneado su código, no hay nada guardado** | "Sin datos disponibles" |
| Recuperación hecha | **Recuperaste lo que Andrea vio hace 6 días. Ahora escanea su código para volver a ver su avance.** | "¡Restauración exitosa!" |
| Recuperar con reto activo | **Ya tienes un reto en curso. Restablécelo primero si quieres recuperar otro.** | "Operación no permitida" |
| Casilla sin fecha | **Sin fecha** | "—" |
| Pareja reinstaló, sin pérdida | **Andrea reinstaló la app** | "Peer ID cambiado" |
| Pareja reinstaló, con pérdida | **Andrea reinstaló la app y perdió parte de su avance** | "Datos del peer inconsistentes" |
| Respaldo, en Ajustes | **Tu respaldo es el teléfono de Andrea. Si pierdes el tuyo, recuperas hasta la última vez que sincronizaron.** | "No se garantiza la persistencia" |

Los errores no piden perdón y nunca son vagos sobre qué pasó. Una pantalla vacía
es una invitación a hacer algo, no un lamento.

Un verbo conserva su nombre en todo el flujo: el botón que dice **Sortear**
produce una casilla **sorteada**; el que dice **Ya lo aparté** produce una
casilla **apartada** en la lista.

---

## 9. Accesibilidad

- Contraste AA en los dos temas, con las razones anotadas en §2.
- **El estado de una casilla nunca depende solo del color**: cambian el grosor
  del contorno, el relleno y el peso del número. Además cada casilla lleva
  `Semantics(label: 'Día 45, $45, pagada')`.
- La pátina es redundante: los días exactos siempre están escritos.
- Objetivos táctiles ≥ 44 dp. Las casillas de 24 dp del tablero se envuelven en
  un `InkWell` de 44 dp con `behavior: opaque`.
- Se respeta el escalado de texto del sistema hasta 1.3×. Por encima de eso, el
  tablero pasa de 12 a 7 columnas.
- Se respeta `MediaQuery.disableAnimations`. Como el MVP no anima, se cumple
  gratis; cuando llegue el sello animado (P1), se salta bajo esa bandera.

---

## 10. Rendimiento

Es un requisito de diseño, no una optimización posterior.

- Sin `BackdropFilter`, sin `BoxShadow`, sin degradados, sin `Opacity` sobre
  subárboles grandes (se usa el canal alfa del color, que no crea una capa).
- El tablero es `SliverGrid.builder`. `InkBox` es `const` cuando puede serlo.
- El QR se genera una sola vez por `stateVersion` y se memoiza en un provider.
  Nunca dentro de `build`.
- Las fuentes van empaquetadas: cero peticiones de red, cero cambio de tipografía
  al arrancar.
