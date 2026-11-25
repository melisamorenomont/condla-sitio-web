# Cómo pedirle cambios a una IA en este sitio

Esta guía es para alguien que no programa y quiere pedirle a una IA (Claude,
ChatGPT, Copilot, etc.) que modifique el sitio. No hace falta entender el
código: alcanza con saber qué carpeta tocar y qué palabras usar al pedirlo.

## Qué es cada carpeta

```
condla-sitio-web/
├── _quarto.yml          # el menú de navegación y el tema del sitio
├── index.qmd            # página "Home"
├── explorar.qmd         # página "Explore the Data" (la interactiva)
├── codebook.qmd         # página "Codebook & Methodology"
├── descargas.qmd        # página "Downloads & Replication"
├── publicaciones.qmd    # página "Publications"
├── equipo.qmd           # página "Team"
├── styles/brand.scss    # los 3 colores de marca y la tipografía
├── data/                # la base de datos que lee la página interactiva
├── descargas/           # el codebook (PDF) y el script de R para descargar
├── publicaciones/        # PDFs propios del equipo (ej. el policy brief)
└── R/validar_datos.R    # un chequeo automático de que la base tiene la
                          # forma esperada (336 filas, 49 columnas)
```

Cada página del menú de arriba es un archivo `.qmd` con ese mismo nombre.
Si querés pedir un cambio en "la página de Publications", el archivo es
`publicaciones.qmd` (los nombres de archivo quedaron en español, el
contenido visible de cada página está en inglés, para seguir el idioma
del codebook).

## Cómo actualizar la base de datos cuando salga una versión nueva

1. Pedile a la IA: *"Reemplazá `data/condla_indices.csv` por esta nueva
   base, manteniendo esos mismos nombres de columna"* (adjuntando el
   archivo nuevo).
2. Si los nombres de columna NO cambiaron (`pais`, `programa`, `ano`,
   `conditionality`, `behaviour_ind`, `monitoring_ind`, `sanctions_ind`,
   `av_vagueness`, etc.), no hace falta tocar nada más: la página
   "Explorar los datos" los usa por nombre, no por posición.
3. Si cambió la cantidad de filas o columnas, pedile a la IA que corra
   `R/validar_datos.R` (puede que haya que actualizar los números 336/49
   ahí adentro si la base creció).
4. Actualizá también, si corresponde, la copia con el nombre original en
   `descargas/` (la que acompaña al script de replicación) y el PDF del
   codebook en `descargas/`.

## Qué es una "celda ojs" (la parte interactiva)

La página "Explore the Data" no es HTML fijo: tiene bloques de código
Observable JS (se ven como ```` ```{ojs} ... ``` ```` en el archivo
`explorar.qmd`) que leen el CSV y arman los filtros y gráficos en el
navegador de quien visita la página, sin necesidad de un servidor.

Las secciones de esa página (Filters, Chart, Data table) son desplegables
(`<details><summary>...</summary>...</details>` en HTML, directamente en
el archivo `.qmd`) — para agregar una nueva sección desplegable, ese es
el patrón a copiar. El selector "View as" (Bars/Lines) es una celda OJS
más: una sola celda de gráfico que elige qué dibujar según ese valor, en
vez de dos gráficos separados.

Para pedir un cambio ahí, podés decir cosas como:

- *"Agregá un filtro por programa, además de por país"*
- *"Cambiá el gráfico de barras para que compare comportamiento, monitoreo
  y sanciones en vez de solo el índice general"*
- *"Hacé que la tabla muestre también la columna `av_vagueness`"*

No hace falta saber JavaScript para pedirlo — con describir qué filtro o
qué gráfico querés alcanza. Un detalle técnico que sí vale la pena conocer:
si un filtro puede devolver una lista vacía (por ejemplo, un país y año sin
datos), pedí explícitamente que se muestre un mensaje tipo "Sin datos para
este filtro" — ya es el patrón que usan los filtros actuales, y evita que
un gráfico se vea roto o vacío sin explicación.

## Dónde están los colores y la tipografía de marca

Todo el estilo visual (los 3 colores: azul marino, durazno y celeste claro)
está en un solo archivo: `styles/brand.scss`. Para pedir un cambio de
estilo ("hacé el navbar más oscuro", "cambiá el color de los botones"),
basta con nombrar ese archivo o describir el cambio — la IA sabe que ahí
vive la paleta.

La portada ya no tiene ilustración (se sacó a pedido): el bloque
`.hero-section` de `index.qmd` es solo texto, con el fondo celeste de
marca como único elemento visual.

## Cómo previsualizar un cambio antes de publicarlo

Con [Quarto](https://quarto.org/docs/get-started/) instalado, desde la
carpeta del sitio:

```
quarto preview
```

Abre el sitio en el navegador con recarga automática cada vez que se
guarda un archivo. Así se puede ver un cambio antes de subirlo a GitHub.

## Cómo publicar un cambio

Una vez que el cambio se ve bien en la previsualización: `git add`,
`git commit`, `git push` a la rama `main` (o pedirle a la IA que lo haga).
El workflow de GitHub Actions (`.github/workflows/publish.yml`) reconstruye
y publica el sitio solo, sin pasos manuales adicionales.
