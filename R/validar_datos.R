# Valida que data/condla_indices.csv tenga exactamente la estructura
# documentada en el codebook publicable (336 filas x 49 columnas, con las
# columnas de identificacion y de indices presentes).

ruta <- file.path("data", "condla_indices.csv")

if (!file.exists(ruta)) {
  stop("No existe ", ruta, " -- copiar la base publicable antes de validar.")
}

df <- read.csv(ruta, stringsAsFactors = FALSE)

columnas_esperadas <- c(
  "pais", "programa", "ano",
  "stringency", "behaviour_ind", "monitoring_ind", "sanctions_ind",
  "av_specification"
)

errores <- character(0)

if (nrow(df) != 336) {
  errores <- c(errores, sprintf("se esperaban 336 filas, hay %d", nrow(df)))
}

if (ncol(df) != 49) {
  errores <- c(errores, sprintf("se esperaban 49 columnas, hay %d", ncol(df)))
}

faltantes <- setdiff(columnas_esperadas, names(df))
if (length(faltantes) > 0) {
  errores <- c(errores, paste("faltan columnas:", paste(faltantes, collapse = ", ")))
}

if (length(errores) > 0) {
  stop("Validacion de datos fallida:\n - ", paste(errores, collapse = "\n - "))
}

cat(sprintf("OK: %d x %d, columnas esperadas presentes\n", nrow(df), ncol(df)))
