# App icon

Fuente: `logo-v1.jpeg` (2048×2048) — el disco sellado rojo sobre `paper`
(`#E8E9E3`), la tinta A del sistema de diseño.

Derivados (regenerables, no editar a mano):

| Archivo | Uso |
|---|---|
| `ic_launcher.png` | Ícono legacy — logo completo, cuadrado, con fondo `paper`. |
| `ic_launcher_fg.png` | Foreground del ícono adaptativo — solo el disco sobre transparencia, casi a sangre. |

## Regenerar

```bash
# 1. legacy (completo, sobre paper)
magick assets/icon/logo-v1.jpeg -resize 1024x1024 -background "#E8E9E3" -flatten \
  assets/icon/ic_launcher.png

# 2. foreground (disco solo; se quita el crema del JPEG, ~#E1E3DE)
magick assets/icon/logo-v1.jpeg -fuzz 8% -transparent "#E1E3DE" -trim +repage \
  -resize 1000x1000 -background none -gravity center -extent 1024x1024 \
  assets/icon/ic_launcher_fg.png

# 3. generar los mipmap/drawable de Android
dart run flutter_launcher_icons
```

Config en `pubspec.yaml` bajo `flutter_launcher_icons:` — fondo adaptativo
`#E8E9E3`, sin iOS.
