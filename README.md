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

1. En `_quarto.yml`, ajustar `site-url` y `repo-url` a tu usuario/repositorio.
2. Subir el proyecto y dejar que corra `.github/workflows/publicar.yml` (push a `main`).
3. En GitHub: **Settings → Pages →**
   - **Source:** Deploy from a branch
   - **Branch:** `gh-pages`
   - **Folder:** `/ (root)`

No uses **main / docs**: GitHub activa Jekyll y falla con el HTML de Quarto. El archivo `.nojekyll` en la salida evita Jekyll; la acción lo genera y publica en `gh-pages`.

La carpeta local `docs/` está en `.gitignore` (se genera con `quarto render`); no hace falta commitearla si usás la acción.

**Sitio de proyecto** (`https://usuario.github.io/cursoR/`): `site-url` debe terminar en `/cursoR/` (con barra final).

## Notas

- El **ejercicio 9** en los fuentes solo tiene enunciado (`ejercicio 10_2022.Rmd`); las soluciones estaban enlazadas externamente. Podés añadir un `*_csol_*` y volver a ejecutar el script.
- Las entregas de alumnos (`entregas/`) están en `.gitignore` y no forman parte del sitio.
- Ajustá en `_quarto.yml` los enlaces `almadana/cursoR` por tu usuario y repositorio reales.
