# Sitio web CONDLA

Sitio estático (Quarto + Observable JS) del proyecto *El condicionamiento de
beneficios sociales en América Latina*. Presenta el proyecto, permite
explorar interactivamente el índice de condicionalidad de la base CONDLA, y
publica para descarga la base, el codebook y el script de replicación.

No tiene backend ni servidor: todo corre como archivos estáticos, servidos
por GitHub Pages.

## Cómo correrlo localmente

Requiere [Quarto](https://quarto.org/docs/get-started/) (y nada más: la
interactividad es Observable JS, se ejecuta en el navegador).

```
quarto preview
```

Abre el sitio en `http://localhost:<puerto>` con recarga automática al
guardar cambios. Para generar el sitio estático final en `_site/`:

```
quarto render
```

## Mantenimiento con ayuda de una IA

Ver [AI_GUIDE.md](AI_GUIDE.md): qué es cada carpeta, cómo actualizar los
datos, dónde están los colores de marca, y qué decirle a una IA para pedir
un cambio sin tener que tocar el código a mano.

## Cómo transferir este sitio a otra cuenta de GitHub

El sitio no tiene nada hardcodeado a una cuenta en particular (ni en el
`.github/workflows/publish.yml`, ni en las páginas). Para pasarlo a otra
cuenta:

1. **Mover el código**: transferir este repositorio (Settings → General →
   Transfer ownership) a la cuenta destino, o crear un repositorio nuevo
   vacío ahí y hacer `git push` de este historial al nuevo remoto.
2. **Habilitar GitHub Pages**: en el repo ya en la cuenta destino, ir a
   Settings → Pages → Build and deployment → Source → **GitHub Actions**
   (el workflow de este repo ya sabe construir y publicar el sitio; solo
   falta decirle a GitHub que lo use).
3. Nada más. El primer push a `main` dispara el workflow y publica el
   sitio en `https://<usuario-o-organización>.github.io/<nombre-del-repo>/`.

(Opcional) completar `website.site-url` en `_quarto.yml` con esa URL una
vez que se conozca, para que los metadatos de la página (links de
compartir, etc.) sean correctos.
