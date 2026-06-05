# Sitio web del Curso de R (Quarto)

Material del curso convertido desde `../clases/curso2.0/` a un **sitio Quarto** autocontenido, listo para [GitHub Pages](https://pages.github.com/).

## Estructura

| Carpeta / archivo | Rol |
|-------------------|-----|
| `_quarto.yml` | Configuración del sitio, menú y salida HTML en `docs/` |
| `index.qmd` | Página de inicio |
| `lecciones/*.qmd` | Sesiones y ejercicios (generados) |
| `input/` | Enlace simbólico a datos en `clases/curso2.0/input` |
| `scripts/convertir_curso.R` | Regenera `.qmd` desde los `.Rmd` originales |

Los ejercicios fusionan el enunciado (`*_ssol_*`) con las soluciones (`*_csol_*`) dentro de un bloque **colapsable** (*Mostrar solución*).

## Uso local

1. Instalar [Quarto](https://quarto.org/docs/download/) (≥ 1.4).
2. Instalar paquetes R que usan las lecciones (`tidyverse`, `lme4`, `emmeans`, `car`, `UsingR`, etc.).
3. Desde esta carpeta:

```bash
quarto render    # genera docs/
quarto preview   # servidor local
```

## Regenerar tras editar R Markdown

En R:

```r
setwd("ruta/a/2025")
source("scripts/convertir_curso.R")
```

Luego `quarto render`.

## Publicar en GitHub Pages

1. Ajustar `site-url` y `repo-url` en `_quarto.yml`.
2. Generar el sitio: `quarto render` (crea/actualiza `docs/`, incluye `.nojekyll`).
3. Commitear y pushear `docs/` junto con el resto del proyecto.
4. En GitHub: **Settings → Pages →**
   - **Source:** Deploy from a branch
   - **Branch:** `main` (o `master`)
   - **Folder:** `/docs`

El archivo `docs/.nojekyll` evita que GitHub use Jekyll (imprescindible para Quarto).

**Sitio de proyecto** (`https://usuario.github.io/cursoR/`): `site-url` debe terminar en `/cursoR/` (con barra final).

## Notas

- El **ejercicio 9** en los fuentes solo tiene enunciado (`ejercicio 10_2022.Rmd`); las soluciones estaban enlazadas externamente. Podés añadir un `*_csol_*` y volver a ejecutar el script.
- Las entregas de alumnos (`entregas/`) están en `.gitignore` y no forman parte del sitio.
- Ajustá en `_quarto.yml` los enlaces `almadana/cursoR` por tu usuario y repositorio reales.
