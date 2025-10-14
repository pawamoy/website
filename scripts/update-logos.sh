#!/usr/bin/env bash

Y=0

increaseY() {
    Y=$((Y + $1))
}

logo2base64() {
    curl -s "$1" | base64 -w 0
}

logo2svgImage() {
    case "$1" in
        *.png) local mime_type="image/png" ;;
        *.svg) local mime_type="image/svg+xml" ;;
        *) echo "Unsupported logo format: $1" >&2; return 1 ;;
    esac
    echo "<image xlink:href=\"data:${mime_type};base64,$(logo2base64 "$1")\" x=\"10\" y=\"$2\" width=\"$3\" height=\"$4\" />"
}

logo2svgLink() {
    echo "<a xlink:href=\"$1\" target=\"_blank\" rel=\"noopener\" aria-label=\"$2\">"
    echo "$3"
    echo "</a>"
}

main() {
    fastapi_logo_url="https://raw.githubusercontent.com/tiangolo/fastapi/master/docs/en/docs/img/logo-margin/logo-teal.png"
    material_logo_url="https://raw.githubusercontent.com/squidfunk/mkdocs-material/master/.github/assets/logo.svg"
    pydantic_logo_url="https://pydantic.dev/assets/for-external/pydantic_logfire_logo_endorsed_lithium_rgb.svg"
    nixtla_logo_dark_url="https://www.nixtla.io/img/logo/full-white.svg"
    nixtla_logo_light_url="https://www.nixtla.io/img/logo/full-black.svg"

    cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="400" height="1000" viewBox="0 0 400 1000" role="img" aria-labelledby="title desc">

  <title id="title">Sponsors</title>
  <desc id="desc">Logos of our sponsors with links to their websites</desc>

  <style>
    /* Default (light mode) */
    .img-dark { display: none; }

    /* Dark mode */
    @media (prefers-color-scheme: dark) {
      .img-light { display: none; }
      .img-dark { display: inline; }
    }
  </style>
EOF

    logo2svgLink "https://fastapi.tiangolo.com/" "FastAPI" "$(logo2svgImage "$fastapi_logo_url" "$Y" "240" "120")"
    increaseY 130
    logo2svgLink "https://squidfunk.github.io/mkdocs-material/" "Material for MkDocs" "$(logo2svgImage "$material_logo_url" "$Y" "240" "240")"
    increaseY 250
    logo2svgLink "https://docs.pydantic.dev/latest/" "Pydantic" "$(logo2svgImage "$pydantic_logo_url" "$Y" "240" "120")"
    increaseY 130
    logo2svgLink "https://www.nixtla.io/" "Nixtla" "$(logo2svgImage "$nixtla_logo_dark_url" "$Y" "120" "60") $(logo2svgImage "$nixtla_logo_light_url" "$Y" "120" "60")"
    increaseY 70

    echo "</svg>"
}

main > docs/assets/sponsors.svg
