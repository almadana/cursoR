# Convierte R Markdown (curso2.0) a Quarto para el sitio web.
# Ejecutar desde la raíz del proyecto: source("scripts/convertir_curso.R")

origen <- normalizePath("../clases/curso2.0", mustWork = TRUE)
destino_lecciones <- normalizePath("lecciones", mustWork = FALSE)
if (!dir.exists(destino_lecciones)) dir.create(destino_lecciones, recursive = TRUE)

sesiones <- list(
  list(
    src = "curso R - sesion 1_2022_variables&indexacion.Rmd",
    out = "01-sesion-variables-indexacion.qmd",
    title = "Sesión 1: variables e indexación"
  ),
  list(
    src = "curso R - sesion 2_2022_funciones.Rmd",
    out = "02-sesion-funciones.qmd",
    title = "Sesión 2: funciones"
  ),
  list(
    src = "curso R - sesion 3_2022_importacion&directorios.Rmd",
    out = "03-sesion-importacion-directorios.qmd",
    title = "Sesión 3: importación y directorios"
  ),
  list(
    src = "curso R - sesion 4_2022_dplyr.Rmd",
    out = "04-sesion-dplyr.qmd",
    title = "Sesión 4: dplyr"
  ),
  list(
    src = "curso R - sesion 5_2022_tidyselect.Rmd",
    out = "05-sesion-tidyselect.qmd",
    title = "Sesión 5: tidyselect"
  ),
  list(
    src = "curso R - sesion 6_2022_pivot.Rmd",
    out = "06-sesion-pivot.qmd",
    title = "Sesión 6: pivot"
  ),
  list(
    src = "curso R - sesion 7_2022_ggplot2.Rmd",
    out = "07-sesion-ggplot2.qmd",
    title = "Sesión 7: ggplot2"
  ),
  list(
    src = "curso R - sesion 8 - modelosLineales1.RMd",
    out = "08-sesion-modelos-lineales-1.qmd",
    title = "Sesión 8: modelos lineales I"
  ),
  list(
    src = "curso R - sesion 9_ medias marginales y pruebas pareadas.Rmd",
    out = "09-sesion-medias-marginales.qmd",
    title = "Sesión 9: medias marginales y contrastes"
  )
)

leer_cuerpo_rmd <- function(path) {
  txt <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (!length(txt)) return(character())
  if (txt[1] != "---") return(txt)
  fin <- which(txt == "---")[2]
  if (is.na(fin)) return(txt)
  txt[-seq_len(fin)]
}

etiqueta_quarto <- function(x) {
  x <- gsub("[^a-zA-Z0-9._-]", "-", x)
  # Quarto exige label como string; los numéricos puros rompen la validación YAML
  if (grepl("^[0-9]+$", x)) paste0("chunk-", x) else x
}

parsear_opciones_chunk <- function(inner) {
  partes <- if (nzchar(inner)) trimws(strsplit(inner, ",", fixed = TRUE)[[1]]) else character()
  label <- NULL
  flags <- character()
  for (o in partes) {
    if (!nzchar(o)) next
    if (grepl("=", o, fixed = TRUE)) {
      if (grepl("^echo\\s*=\\s*F", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| echo: false")
      } else if (grepl("^include\\s*=\\s*F", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| include: false")
      } else if (grepl("^eval\\s*=\\s*F", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| eval: false")
      } else if (grepl("^warning\\s*=\\s*F", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| warning: false")
      } else if (grepl("^message\\s*=\\s*F", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| message: false")
      } else if (grepl("^error\\s*=\\s*T", o, ignore.case = TRUE)) {
        flags <- c(flags, "#| error: true")
      }
    } else {
      label <- if (is.null(label)) o else paste(label, o)
    }
  }
  if (!is.null(label) && nzchar(label)) {
    flags <- c(paste0("#| label: ", etiqueta_quarto(label)), flags)
    if (grepl("error", label, ignore.case = TRUE)) {
      flags <- c("#| eval: false", flags)
    }
  }
  flags
}

normalizar_chunks <- function(txt) {
  res <- character()
  i <- 1
  while (i <= length(txt)) {
    line <- txt[i]
    if (grepl("^```\\s*\\{r", line)) {
      inner <- sub("^```\\s*\\{r\\s*", "", sub("\\}\\s*$", "", line))
      flags <- parsear_opciones_chunk(inner)
      bloque <- c("```{r}", flags)
      # Código con error de sintaxis a propósito (no se puede ejecutar)
      j <- i + 1
      while (j <= length(txt) && !grepl("^```\\s*$", txt[j])) j <- j + 1
      if (j <= length(txt)) {
        cuerpo <- paste(txt[seq(i + 1, j - 1)], collapse = "\n")
        sin_eval <- grepl("#| eval: false", paste(bloque, collapse = "\n"), fixed = TRUE)
        if (!sin_eval && grepl("=\\s*[A-Za-z]+\\s+[A-Za-z]+\\s*$", cuerpo, perl = TRUE)) {
          bloque <- c("```{r}", "#| eval: false", flags)
          sin_eval <- TRUE
        }
        # load() de archivos que el alumno genera en clase, no están en input/
        if (!sin_eval && grepl("\\bload\\s*\\(\\s*['\"](?!input/)", cuerpo, perl = TRUE)) {
          bloque <- c("```{r}", "#| eval: false", flags)
        }
        if (!sin_eval && grepl("\\bsave\\.image\\s*\\(", cuerpo)) {
          bloque <- c("```{r}", "#| eval: false", flags)
        }
        if (!sin_eval && grepl("\\bsetwd\\s*\\(", cuerpo)) {
          bloque <- c("```{r}", "#| eval: false", flags)
        }
      }
      bloque <- unique(bloque)
      res <- c(res, bloque)
    } else {
      res <- c(res, line)
    }
    i <- i + 1
  }
  res
}

arreglar_rutas <- function(txt) {
  gsub("\\./input/", "input/", txt, fixed = FALSE)
}

arreglar_separadores <- function(txt) {
  # En Quarto, una línea solo con --- en el cuerpo rompe el parser YAML
  gsub("^---$", "***", txt, perl = TRUE)
}

prefijar_labels_chunks <- function(txt, prefijo = "sol-") {
  gsub("^#\\| label: ([^\\s]+)", paste0("#| label: ", prefijo, "\\1"), txt, perl = TRUE)
}

yaml_quarto <- function(title, tipo = c("sesion", "ejercicio")) {
  tipo <- match.arg(tipo)
  c(
    "---",
    paste0("title: \"", gsub("\"", "\\\\\"", title), "\""),
    "author:",
    "  - Camila Zugarramurdi",
    "  - Álvaro Cabana",
    "date: \"2022\"",
    "lang: es",
    if (tipo == "ejercicio") {
      c(
        "code-fold: false",
        "code-tools: true"
      )
    } else {
      character()
    },
    "---",
    "",
    "```{r}",
    "#| include: false",
    "knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)",
    "if (!file.exists(\"input\") && file.exists(\"../input\")) {",
    "  knitr::opts_knit$set(root.dir = normalizePath(\"..\"))",
    "}",
    "```",
    ""
  )
}

extraer_solucion <- function(ssol_body, csol_body) {
  mark <- grep(
    "A continuación se presenta|^[#]{1,3}\\s*Soluciones|conjunto de soluciones posibles",
    csol_body,
    ignore.case = TRUE
  )
  if (length(mark)) {
    sol <- csol_body[seq(mark[1], length(csol_body))]
    sol <- sol[!grepl("^>\\s*A continuación", sol)]
    return(sol)
  }
  n <- min(length(ssol_body), length(csol_body))
  k <- 0L
  for (i in seq_len(n)) {
    if (trimws(ssol_body[i]) != trimws(csol_body[i])) break
    k <- as.integer(i)
  }
  if (k >= length(csol_body)) return(NULL)
  sol <- csol_body[seq(k + 1L, length(csol_body))]
  while (length(sol) && grepl("^[-]{3,}\\s*$|^\\s*$", sol[1])) {
    sol <- sol[-1]
  }
  if (!length(sol)) NULL else sol
}

archivo_ejercicio <- function(n, tipo = c("ssol", "csol")) {
  tipo <- match.arg(tipo)
  nn <- as.integer(n)
  tag <- if (tipo == "ssol") "ssol" else "csol"
  candidatos <- list.files(
    origen,
    pattern = sprintf("ejercicio[ _-]*%d.*%s.*2022\\.Rmd$", nn, tag),
    ignore.case = TRUE,
    full.names = TRUE
  )
  if (!length(candidatos)) {
    stop("No encuentro ejercicio ", nn, " (", tipo, ") en ", origen)
  }
  candidatos[1]
}

convertir_sesion <- function(info) {
  src <- file.path(origen, info$src)
  if (!file.exists(src)) stop("Falta: ", src)
  body <- leer_cuerpo_rmd(src)
  body <- normalizar_chunks(body)
  body <- arreglar_rutas(body)
  body <- arreglar_separadores(body)
  out <- c(yaml_quarto(info$title, "sesion"), body)
  writeLines(out, file.path(destino_lecciones, info$out), useBytes = TRUE)
  message("Sesión -> ", info$out)
}

convertir_ejercicio <- function(n) {
  nn <- as.integer(n)
  path_ssol <- if (nn == 9) {
    file.path(origen, "curso R - ejercicio 10_2022.Rmd")
  } else {
    archivo_ejercicio(nn, "ssol")
  }
  if (!file.exists(path_ssol)) stop("Falta enunciado ejercicio ", nn)
  ssol <- leer_cuerpo_rmd(path_ssol)
  csol <- if (nn == 9) NULL else leer_cuerpo_rmd(archivo_ejercicio(nn, "csol"))
  sol <- if (!is.null(csol)) extraer_solucion(ssol, csol) else NULL
  body <- normalizar_chunks(ssol)
  body <- arreglar_rutas(body)
  body <- arreglar_separadores(body)
  out <- c(yaml_quarto(sprintf("Ejercicio %d", n), "ejercicio"), body)
  if (!is.null(sol) && length(sol)) {
    sol <- normalizar_chunks(sol)
    sol <- arreglar_rutas(sol)
    sol <- arreglar_separadores(sol)
    sol <- prefijar_labels_chunks(sol)
    out <- c(
      out,
      "",
      "------------------------------------------------------------------------",
      "",
      "::: {.callout-tip .callout-solution collapse=\"true\"}",
      "## Soluciones",
      "",
      "Desplegá esta sección cuando quieras comparar con un conjunto de soluciones posibles.",
      "",
      sol,
      ":::"
    )
  }
  fname <- sprintf("ejercicio-%02d.qmd", n)
  writeLines(out, file.path(destino_lecciones, fname), useBytes = TRUE)
  message("Ejercicio -> ", fname)
}

invisible(lapply(sesiones, convertir_sesion))
invisible(lapply(1:10, convertir_ejercicio))
message("Listo: ", destino_lecciones)
