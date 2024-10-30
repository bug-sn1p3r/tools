# Host Header Checker

## Descripción
**Host Header Checker** es una herramienta sencilla diseñada para detectar posibles vulnerabilidades de inyección de encabezados host en servidores web. Permite enviar múltiples encabezados personalizados y verificar si alguno de ellos se refleja en la respuesta del servidor.

## Características
- Carga dominios desde un archivo `.txt`.
- Soporta múltiples métodos de inyección.
- Permite personalizar encabezados.
- Muestra resultados en un formato claro y directo.

## Requisitos
- Bash
- cURL

## Uso
```bash
./host_header_checker.sh [-f <archivo_de_dominios>] [-n <número_de_coincidencias>] [-p <encabezado_personalizado>] [-h]
