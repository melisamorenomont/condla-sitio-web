# Sitio web CONDLA — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publicar un sitio estático en GitHub Pages que presenta el proyecto CONDLA, permite explorar interactivamente el índice de condicionalidad, y ofrece para descarga la base publicable (49 variables), el codebook y el script de replicación — todo transferible a otra cuenta de GitHub.

**Architecture:** Sitio Quarto (`type: website`), build 100 % estático sin backend. Las páginas de contenido son `.qmd` en español; la página interactiva (`explorar.qmd`) usa celdas Observable JS (`ojs`) que leen `data/condla_indices.csv` vía `FileAttachment` y renderizan filtros + gráficos (Plot/D3) en el navegador. Despliegue vía GitHub Actions (`quarto render` → `gh-pages`).

**Tech Stack:** Quarto (website project), Observable JS (`ojs` cells, Observable Plot), SCSS para el tema de marca, GitHub Actions + `quarto-actions`.

**Spec:** Diseño acordado en conversación (brainstorming), verificado contra los archivos publicables reales en `C:\Users\melim\Dropbox\Update CONDLA 2026\CONDLA\Base, script y codebook final\` (CSV de 336 filas × 49 columnas, `CONDLA_indices_codebook_v1.pdf`, `Script publicable CONDLA_v1.qmd`) — ver resumen de verificación en este mismo plan, sección "Datos verificados".

## Datos verificados (no repetir el chequeo — ya hecho)

- **CSV**: `Base de datos con variables orig e indices cond y vague (49 variables) 2026.csv` — 336 filas de datos + 1 encabezado, 49 columnas. Encabezado coincide EXACTAMENTE con el orden documentado en el codebook (4 identificadores + 36 variables codificadas + 4 índices + 5 de vaguedad).
- **Codebook**: `CONDLA_indices_codebook_v1.pdf` (32 págs) — describe 28 programas, 16 países, 336 obs, período real **1997–2026** (no 1997-2019/2020 como en el paper/nota metodológica más viejos — esos quedaron desactualizados, usar estos datos nuevos).
- **Script**: `Script publicable CONDLA_v1.qmd` — cada fórmula (cond_edu, cond_health, behaviour_ind, monitoring_ind, sanc_edu/health/otros, sanctions_ind, conditionality, av_vagueness) coincide exactamente con las ecuaciones 1–19 del codebook. Sin inconsistencias.
- Missing values: la columna `conditionality` tiene 14 de 336 observaciones en `NA` (documentado en codebook §5.7) — **no imputar, no graficar como 0**.
- Valores faltantes en el CSV están como texto literal `NA` (salida de `write_csv` de R).

## Global Constraints

- Sitio 100% estático — sin servidor, sin backend, compatible con GitHub Pages de cualquier cuenta.
- Debe ser transferible a otra cuenta de GitHub sin tocar código (solo settings + remote).
- Todo el contenido en español.
- Solo se publican materiales de autoría del propio equipo: el CSV de 49 variables, el codebook, el script, los PDFs ya publicados (paper/policy brief/nota metodológica) y copy institucional — **nunca** los archivos fuente de `Países/` (recortes de prensa, manuales operativos de terceros, etc.).
- El dataset publicado es exactamente `Base de datos con variables orig e indices cond y vague (49 variables) 2026.csv` (336×49) — cualquier cambio futuro debe mantener ese nombre de columnas o actualizar `explorar.qmd` en consecuencia.
- Paleta de marca: azul marino `#1B3B6F`, durazno `#F2C6A0`, fondo celeste claro `#D8E0ED` (tomados por muestreo de las portadas/WordPress — confirmar con las investigadoras si existe un archivo de marca oficial con valores exactos).
- Interactividad en Observable JS (`ojs`), datos vía `FileAttachment("data/condla_indices.csv")`.

## Review Focus

1. **Strings "NA" del CSV** — `FileAttachment.csv({typed:true})` debe convertir "NA" a `null`/`NaN`, no dejarlo como texto; si no, los filtros numéricos y gráficos fallan en silencio. → cubierto en Task 3.
2. **Filas sin `conditionality` (14 de 336)** — deben excluirse o marcarse explícitamente como "sin dato", nunca graficarse como 0 (cambiaría el significado: "sin medición" ≠ "sin condicionalidad"). → cubierto en Task 3.
3. **Rango de años por programa** — no todos los programas cubren 1997–2026 (ver Tabla 3 del codebook); un slider de año global no debe sugerir datos donde no los hay — mostrar "sin datos para este filtro" en vez de un gráfico vacío/roto. → cubierto en Task 3.
4. **Transferencia a otra cuenta de GitHub** — URLs de Pages, `_quarto.yml: website.site-url`, y rutas de descarga no deben quedar hardcodeadas a una cuenta/usuario específico. → cubierto en Task 7 con checklist explícita.
5. **Rutas relativas en GitHub Pages con subpath** — si el repo no se llama `usuario.github.io`, el sitio se sirve bajo `/condla-sitio-web/`; los links de descarga y `FileAttachment` deben seguir funcionando ahí, no solo en `quarto preview` local. → cubierto en Task 7.

---

## File Structure

```
condla-sitio-web/
├── _quarto.yml                          # nav, tema, site-url
├── index.qmd                            # Inicio
├── explorar.qmd                         # Explorar los datos (OJS)
├── codebook.qmd                         # Codebook y metodología
├── descargas.qmd                        # Descargas y réplica
├── publicaciones.qmd
├── equipo.qmd
├── styles/
│   └── brand.scss                       # paleta + tipografía de marca
├── data/
│   └── condla_indices.csv               # copia verbatim del CSV verificado
├── descargas/
│   ├── CONDLA_indices_codebook_v1.pdf
│   └── Script_publicable_CONDLA_v1.qmd
├── img/
│   └── hero.(png|svg)                   # ilustración de marca
├── R/
│   └── validar_datos.R                  # validación de estructura del CSV
├── .github/workflows/publish.yml
├── README.md                            # qué es esto + cómo transferirlo
└── AI_GUIDE.md                          # manual para pedirle cambios a una IA
```

---

### Task 1: Scaffold del sitio Quarto + tema de marca

**Files:**
- Create: `_quarto.yml`
- Create: `styles/brand.scss`
- Create: `index.qmd`, `explorar.qmd`, `codebook.qmd`, `descargas.qmd`, `publicaciones.qmd`, `equipo.qmd` (placeholders con título únicamente)
- Create: `.gitignore`
- Create: `img/hero.png` (o `.svg`)

**Interfaces:**
- Produces: estructura de navegación (`_quarto.yml: website.navbar`) con 6 entradas que las tareas siguientes rellenan; variables SCSS `$navy: #1B3B6F`, `$peach: #F2C6A0`, `$bg-light: #D8E0ED` que las tareas 2-6 reutilizan.

- [ ] **Step 1:** Crear `_quarto.yml` con `project: {type: website}`, `website: {title: "CONDLA", navbar: {left: [Inicio, "Explorar los datos", "Codebook y metodología", "Descargas y réplica", Publicaciones, Equipo]}}`, `format: html: {theme: [cosmo, styles/brand.scss]}`.
- [ ] **Step 2:** Crear `styles/brand.scss` con las 3 variables de color de marca y su uso en `navbar-bg`, `body-bg`, headings.
- [ ] **Step 3:** Crear los 6 `.qmd` con únicamente `# <Título>` cada uno.
- [ ] **Step 4:** Conseguir/crear `img/hero.png` (ilustración de manos y nubes en la paleta de marca) — si no hay derechos confirmados sobre la ilustración original del WordPress/policy brief, usar un ícono o ilustración libre de derechos en la misma paleta como placeholder y anotarlo en `AI_GUIDE.md` como pendiente.
- [ ] **Step 5: Verificar** — correr `quarto preview` desde la carpeta del repo. Esperado: sirve localhost con las 6 páginas navegables, tema de marca visible (fondo/navbar en los colores definidos).
- [ ] **Step 6: Commit**
```bash
git init
git add _quarto.yml styles/ *.qmd .gitignore img/
git commit -m "scaffold: estructura inicial del sitio Quarto con tema de marca"
```

---

### Task 2: Publicar datos, codebook y script + validación de consistencia

**Files:**
- Create: `data/condla_indices.csv` (copia de `Base de datos con variables orig e indices cond y vague (49 variables) 2026.csv`)
- Create: `descargas/CONDLA_indices_codebook_v1.pdf`
- Create: `descargas/Script_publicable_CONDLA_v1.qmd`
- Create: `R/validar_datos.R`

**Interfaces:**
- Produces: `data/condla_indices.csv` con las 49 columnas exactas que `explorar.qmd` (Task 3) consume por nombre: `pais`, `programa`, `ano`, `conditionality`, `behaviour_ind`, `monitoring_ind`, `sanctions_ind`, `av_vagueness`.

- [ ] **Step 1:** Copiar los 3 archivos verbatim desde `C:\Users\melim\Dropbox\Update CONDLA 2026\CONDLA\Base, script y codebook final\` a las rutas de arriba (renombrando el CSV a `condla_indices.csv` por brevedad de URL).
- [ ] **Step 2: Escribir `R/validar_datos.R`** que lea `data/condla_indices.csv` y falle (`stop()`) si: `nrow(df) != 336`, `ncol(df) != 49`, o si falta alguna de las columnas `conditionality, behaviour_ind, monitoring_ind, sanctions_ind, av_vagueness, pais, programa, ano`.
- [ ] **Step 3: Run:** `Rscript R/validar_datos.R` — Expected: termina sin error, imprime "OK: 336×49, columnas esperadas presentes".
- [ ] **Step 4: Commit**
```bash
git add data/ descargas/ R/validar_datos.R
git commit -m "data: publicar base CONDLA 49 variables, codebook y script de replicación"
```

---

### Task 3: Página "Explorar los datos" (interactividad OJS)

**Files:**
- Modify: `explorar.qmd`

**Interfaces:**
- Consumes: `data/condla_indices.csv` (Task 2) — columnas `pais` (string), `ano` (number), `conditionality|behaviour_ind|monitoring_ind|sanctions_ind` (number o `null`), `programa` (string).
- Produces: nada que otra tarea consuma (página hoja).

- [ ] **Step 1:** Celda `ojs` que carga los datos:
```js
data = FileAttachment("data/condla_indices.csv").csv({typed: true})
```
- [ ] **Step 2:** Celda `ojs` de normalización que convierte el string `"NA"` a `null` explícitamente para las columnas índice (typed:true de d3 ya interpreta números vacíos como NaN, pero el texto `"NA"` debe mapearse aparte):
```js
clean = data.map(d => ({
  ...d,
  conditionality: d.conditionality === "NA" ? null : +d.conditionality,
  behaviour_ind: d.behaviour_ind === "NA" ? null : +d.behaviour_ind,
  monitoring_ind: d.monitoring_ind === "NA" ? null : +d.monitoring_ind,
  sanctions_ind: d.sanctions_ind === "NA" ? null : +d.sanctions_ind
}))
```
- [ ] **Step 3:** Controles `ojs` (Inputs.checkbox para país, Inputs.range para año) ligados al dominio real de `clean` (min/max de `ano`, valores únicos de `pais`), no a un rango fijo hardcodeado — así cada programa solo muestra su propio rango (Review Focus #3).
- [ ] **Step 4:** Celda derivada `filtered` que aplica ambos filtros sobre `clean` y, si `filtered.length === 0`, la celda del gráfico debe mostrar el texto "Sin datos para este filtro" en vez de un gráfico vacío.
- [ ] **Step 5:** Gráfico 1 (Observable Plot, barras): índice de condicionalidad por país para el año seleccionado — excluir explícitamente `d.conditionality === null` del `Plot.barY` (Review Focus #2), no convertir a 0.
- [ ] **Step 6:** Gráfico 2 (Observable Plot, líneas): evolución del índice 2000–2026 para los países seleccionados.
- [ ] **Step 7:** Tabla (`Inputs.table(filtered)`) buscable/ordenable con las columnas principales.
- [ ] **Step 8: Verificar** — `quarto render explorar.qmd`, abrir el HTML resultante en el navegador (usar el browser pane), confirmar: (a) cambiar el filtro de país actualiza ambos gráficos, (b) un filtro sin resultados muestra el mensaje en vez de romperse, (c) ninguna fila con `conditionality = null` aparece como barra en 0.
- [ ] **Step 9: Commit**
```bash
git add explorar.qmd
git commit -m "feat: pagina interactiva de exploracion de datos (OJS)"
```

---

### Task 4: Página "Codebook y metodología"

**Files:**
- Modify: `codebook.qmd`

**Interfaces:**
- Consumes: contenido textual de `CONDLA_indices_codebook_v1.pdf` (secciones 1-6) — no un archivo de datos.

- [ ] **Step 1:** Escribir el concepto en 3 niveles (condicionalidad → comportamiento/monitoreo/sanciones → indicadores) con la tabla de las 36 variables codificadas, agrupadas por dimensión (igual estructura que la Sección 4 del codebook).
- [ ] **Step 2:** Mostrar las fórmulas clave (ecuaciones 8, 9, 11, 16, 17, 19 del codebook) en bloques de matemática de Quarto (`$$...$$`).
- [ ] **Step 3:** Nota explícita sobre los 14 casos sin `conditionality` (Tabla 4 del codebook) y por qué no se imputan.
- [ ] **Step 4: Verificar** — `quarto render codebook.qmd` sin errores, fórmulas se renderizan correctamente (revisar visualmente).
- [ ] **Step 5: Commit**
```bash
git add codebook.qmd
git commit -m "docs: pagina de codebook y metodologia del indice"
```

---

### Task 5: Página "Descargas y réplica"

**Files:**
- Modify: `descargas.qmd`

**Interfaces:**
- Consumes: archivos de `data/` y `descargas/` creados en Task 2 (rutas relativas).

- [ ] **Step 1:** Links de descarga directa a `data/condla_indices.csv`, `descargas/CONDLA_indices_codebook_v1.pdf`, `descargas/Script_publicable_CONDLA_v1.qmd`.
- [ ] **Step 2:** Instrucciones breves "cómo replicar": instalar R + paquete `tidyverse`, abrir el `.qmd` en RStudio/Positor, render — el script ya apunta al CSV de 49 variables como input/output.
- [ ] **Step 3: Verificar** — `quarto render descargas.qmd`; abrir la página y confirmar que los 3 links descargan el archivo correcto (no 404).
- [ ] **Step 4: Commit**
```bash
git add descargas.qmd
git commit -m "docs: pagina de descargas y replicacion"
```

---

### Task 6: Páginas institucionales (Inicio, Publicaciones, Equipo)

**Files:**
- Modify: `index.qmd`, `publicaciones.qmd`, `equipo.qmd`

**Interfaces:**
- Consumes: copy recopilado de `condicionalidades.wordpress.com` (Inicio: "sobre el proyecto" + 3 preguntas de investigación; Publicaciones: los 4 ítems con resumen; Equipo: bios ya relevadas) y `img/hero.png` (Task 1).

- [ ] **Step 1:** `index.qmd` — hero con `img/hero.png`, "Sobre el proyecto" y las 3 preguntas (Modelos de condicionalidades / Decisiones gubernamentales / Percepciones ciudadanas), igual que la home actual del WordPress.
- [ ] **Step 2:** `publicaciones.qmd` — los 4 papers/policy brief con resumen y, donde exista, link al PDF correspondiente del repo de investigación o al DOI.
- [ ] **Step 3:** `equipo.qmd` — bios ya relevadas (Rossel, Antía, López Cariboni, Manzi, Menéndez González, Osorio, +contactos); pedir a las investigadoras confirmar si falta alguien de la base.
- [ ] **Step 4: Verificar** — `quarto render` completo (las 6 páginas), revisar que no haya links rotos (`quarto render` reporta errores de referencia faltante si los hay).
- [ ] **Step 5: Commit**
```bash
git add index.qmd publicaciones.qmd equipo.qmd
git commit -m "docs: contenido institucional (inicio, publicaciones, equipo)"
```

---

### Task 7: Despliegue y portabilidad a otra cuenta de GitHub

**Files:**
- Create: `.github/workflows/publish.yml`
- Create/Modify: `README.md`
- Modify: `_quarto.yml` (agregar `website.site-url` con comentario de cómo cambiarlo)

**Interfaces:**
- Consumes: todo el repo construido en Tasks 1-6.

- [ ] **Step 1:** `.github/workflows/publish.yml` — workflow genérico (sin nombre de cuenta/usuario hardcodeado) que en cada push a `main` corre `quarto render` y publica a la rama `gh-pages` (acción oficial `quarto-dev/quarto-actions/publish`).
- [ ] **Step 2:** `README.md` con 3 secciones: (a) qué es el sitio, (b) cómo correrlo localmente (`quarto preview`), (c) **"Cómo transferir este sitio a otra cuenta de GitHub"**: 1) transferir el repo (Settings → Transfer ownership) o crear uno nuevo en la cuenta destino y hacer push del remoto, 2) habilitar GitHub Pages apuntando a la rama `gh-pages`, 3) nada más — el workflow y las rutas son relativas.
- [ ] **Step 3:** Confirmar que ningún archivo del repo tiene una URL absoluta a una cuenta de GitHub específica (buscar `github.io`/`github.com/<usuario>` en todos los `.qmd`/`.yml`); si aparece alguna, volverla relativa o parametrizarla.
- [ ] **Step 4: Verificar** — push a un repo de prueba en GitHub, confirmar que Actions corre sin error y que la página se sirve correctamente bajo `/<nombre-repo>/` (cubre Review Focus #5: rutas con subpath).
- [ ] **Step 5: Commit**
```bash
git add .github/workflows/publish.yml README.md _quarto.yml
git commit -m "ci: despliegue a GitHub Pages + instrucciones de portabilidad"
```

---

### Task 8: Manual breve para pedirle cambios a una IA

**Files:**
- Create: `AI_GUIDE.md`

**Interfaces:**
- Consumes: todo lo anterior (es un documento, no código).

- [ ] **Step 1:** Escribir `AI_GUIDE.md` con, como mínimo: (a) qué es cada carpeta (mapa del "File Structure" de este plan), (b) cómo actualizar los datos cuando salga una versión nueva de la base — reemplazar `data/condla_indices.csv` manteniendo esos nombres de columna, correr `R/validar_datos.R`, nada más cambia en `explorar.qmd` si los nombres de columna no cambian, (c) dónde están los colores/tipografía de marca (`styles/brand.scss`) para pedir cambios de estilo, (d) qué es una celda `ojs` y un ejemplo mínimo, para que alguien sin JS pueda describirle a una IA "agregá un filtro por dimensión" con las palabras correctas, (e) cómo previsualizar (`quarto preview`) y desplegar (push a `main`) un cambio.
- [ ] **Step 2: Verificar** — releer el documento imaginando que quien lo usa no sabe programar: ¿alcanza para pedirle a una IA "agregá X" sin tener que abrir el código primero?
- [ ] **Step 3: Commit**
```bash
git add AI_GUIDE.md
git commit -m "docs: manual breve para mantener el sitio con ayuda de una IA"
```

---

## Self-Review

1. **Cobertura del spec:** interactividad OJS (Task 3) ✓, descarga de base/codebook/script (Task 2, 5) ✓, portabilidad (Task 7) ✓, estilo WordPress (Task 1, 6) ✓, esquema tipo Knotz (nav de Task 1 + Task 3/5) ✓, manual para IA (Task 8) ✓. Sin huecos.
2. **Pasos:** cada step deja una sola cosa razonable por escribir; los pasos de "Verificar" tienen comando + resultado esperado concretos.
3. **Consistencia de nombres:** `data/condla_indices.csv` se nombra igual en Task 2 (produce) y Task 3/5 (consume); columnas (`pais`, `ano`, `conditionality`, etc.) iguales en todas las tareas que las usan.
4. **Review Focus:** los 5 puntos están cada uno asignado a un step concreto (ver referencias "(Review Focus #N)" en Tasks 2, 3, 7).
5. **Proporción:** el plan es más largo que el "código" real (son 6 páginas Quarto + 1 script de validación + 1 workflow), pero cada bloque de código es una celda/fórmula puntual que la fuente ya fija (ecuaciones del codebook, nombres de columna reales) — no hay transcripción completa de páginas.
