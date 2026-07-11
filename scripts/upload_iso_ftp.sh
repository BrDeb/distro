#!/usr/bin/env bash
# upload_iso_ftp.sh
#
# Função para enviar uma ISO via FTP para um diretório remoto,
# removendo antes qualquer .iso antiga que esteja lá (substituição).
#
# Requer: lftp instalado (sudo apt-get install -y lftp)
#
# Uso:
#   source upload_iso_ftp.sh
#   upload_iso_ftp "<host>" "<user>" "<senha>" "<dir_remoto>" "<arquivo_iso_local>" ["yes|no" ssl]
#
# Exemplo:
#   upload_iso_ftp "ftp.exemplo.com" "usuario" "senha123" "/misc/" "BrDeb-amd64.hybrid.iso"

set -uo pipefail

upload_iso_ftp() {
    local ftp_host="$1"
    local ftp_user="$2"
    local ftp_pass="$3"
    local remote_dir="$4"
    local local_iso="$5"
    local ftp_ssl="${6:-no}"   # "yes" se o servidor exigir FTPS explícito

    if [[ ! -f "$local_iso" ]]; then
        echo "[upload_iso_ftp] Erro: arquivo '$local_iso' não encontrado." >&2
        return 1
    fi

    if ! command -v lftp >/dev/null 2>&1; then
        echo "[upload_iso_ftp] Erro: lftp não está instalado (sudo apt-get install -y lftp)." >&2
        return 1
    fi

    local iso_name
    iso_name="$(basename "$local_iso")"

    echo "[upload_iso_ftp] Conectando em $ftp_host, limpando ISOs antigas em $remote_dir e enviando $iso_name..."

    lftp -u "${ftp_user},${ftp_pass}" "$ftp_host" <<EOF
set ftp:ssl-allow ${ftp_ssl}
set net:max-retries 3
set net:timeout 20
set cmd:fail-exit no
mkdir -p ${remote_dir}
set cmd:fail-exit yes
cd ${remote_dir}
set cmd:fail-exit no
mrm *.iso
set cmd:fail-exit yes
put "${local_iso}" -o "${iso_name}"
bye
EOF

    local status=$?
    if [[ $status -ne 0 ]]; then
        echo "[upload_iso_ftp] Falha no upload (status $status)." >&2
        return "$status"
    fi

    echo "[upload_iso_ftp] Upload concluído: ${iso_name} -> ${ftp_host}${remote_dir}"
    return 0
}

# Permite rodar o script diretamente (não só via `source`), passando os args na linha de comando.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    upload_iso_ftp "$@"
fi