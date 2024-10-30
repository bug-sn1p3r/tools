#!/bin/bash

# imprimo el banner
print_banner() {
    echo -e "\e[36m"
    echo -e "==============================================="
    echo -e "             HOST HEADER CHECKER               "
    echo -e "             VERSION 0.0.2                     "
    echo -e "==============================================="
    echo -e "\e[0m"
}

# help function
show_help() {
    echo "Uso: $0 [-f <archivo_de_dominios>] [-n <número_de_coincidencias>] [-p <encabezado_personalizado>] [-h]"
    echo ""
    echo "Flags:"
    echo "  -f    Especificar el archivo .txt que contiene los dominios"
    echo "  -n    Número máximo de coincidencias encontradas para mostrar (por defecto 5)"
    echo "  -p    Añadir un encabezado personalizado"
    echo "  -h    Mostrar esta ayuda"
    exit 0
}

# leo el archivo de los dominios
read_domains() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        mapfile -t domains < "$file_path"
        echo "${domains[@]}"
    else
        echo -e "\e[31mError al leer el archivo: $file_path\e[0m"
        exit 1
    fi
}

# run
run_curl() {
    local url="$1"
    shift
    local headers=("$@")
    local cmd=("curl" "-m" "10" "-s" "$url")
    for header in "${headers[@]}"; do
        cmd+=("-H" "$header")
    done

    output=$("${cmd[@]}" 2>&1 | tr '[:upper:]' '[:lower:]')
    echo "$output"
}

# Métodos
method_1() {
    local domain="$1"
    local headers=("X-Forwarded-Host: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 1
}

method_2() {
    local domain="$1"
    local headers=("Forwarded: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 2
}

method_3() {
    local domain="$1"
    local headers=("X-Forwarded-For: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 3
}

method_4() {
    local domain="$1"
    local headers=("X-Client-IP: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 4
}

method_5() {
    local domain="$1"
    local headers=("X-Remote-Addr: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 5
}

method_6() {
    local domain="$1"
    local headers=("X-Forwarded-Proto: https" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 6
}

method_7() {
    local domain="$1"
    local headers=("X-Host: evil.com.co" "${custom_headers[@]}")
    check_protocols "$domain" "${headers[@]}" 7
}

# pronto implementare varios protocolos como http y https
check_protocols() {
    local domain="$1"
    shift
    local headers=("$@")
    local protocols=("https")

    for protocol in "${protocols[@]}"; do
        local url="$protocol://$domain"
        output=$(run_curl "$url" "${headers[@]}")

        if echo "$output" | grep -q "evil.com.co"; then
            echo ""
            echo -e "\e[31m[ALERTA] 'evil.com.co' encontrado en $url con el método #$2\e[0m"
            echo -e "\e[37m[POC] Prueba de concepto:"
            echo -e "curl -m 10 -s $url -H ${headers[*]}"
            echo ""
            
            echo "$output" | grep -o ".\{0,30\}evil\.com\.co.\{0,30\}" | head -n 5

        else
            echo -e "\e[32m[OK] 'evil.com.co' no encontrado en $url con el método #$2\e[0m"
        fi
    done
}

# main
main() {
    local domains=()
    custom_headers=()
    max_matches=1

    if [[ $# -eq 0 ]]; then
        show_help
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -f)
                file="$2"
                domains=($(read_domains "$file"))
                shift 2
                ;;
            -n)
                max_matches="$2"
                shift 2
                ;;
            -p)
                custom_headers+=("$2")
                shift 2
                ;;
            -h)
                show_help
                ;;
            *)
                echo -e "\e[31mOpción no válida: $1\e[0m"
                show_help
                ;;
        esac
    done

    if [[ ${#domains[@]} -eq 0 ]]; then
        echo -e "\e[31mError: No se han cargado dominios. Usa la opción -f para especificar un archivo de dominios.\e[0m"
        exit 1
    fi

    print_banner
    echo -e "\e[33mSe han cargado ${#domains[@]} dominios desde el archivo.\e[0m"

    for domain in "${domains[@]}"; do
        echo "----------------------------------------------------------------------------------------"
        method_1 "$domain"
        method_2 "$domain"
        method_3 "$domain"
        method_4 "$domain"
        method_5 "$domain"
        method_6 "$domain"
        method_7 "$domain"
    done
}

# run main
main "$@"
