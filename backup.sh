#!/bin/bash

DEFAULT_DAYS=7
PATH_BK="$HOME"
OUT_DIR="$(pwd)"

main(){
    def_arg $@ || $(echo "A definição de variáveis a partir dos argumentos falhou" && exit 1)
    ls "$OUT_DIR" >/dev/null 2>&1 || mkdir -p "$OUT_DIR"
    while true ; do
        dif_date_in_days
        if [ -f "$RECENT_BK" ] ; then
            read -p "O último arquivo de backup, '$RECENT_BK', foi criado a menos de $DEFAULT_DAYS. Deseja substituílo? Y/n: " response
            echo
            case $response in
                [Yy] )
                    echo -e "\nDeletando '$RECENT_BK'..."
                    rm -f "$RECENT_BK" || $(echo -e "\nErro ao deletar arquivo" && exit 1)
                    create_bk
                    break
                ;;
                [Nn] )
                    create_bk
                    break
                ;;
                * )
                    echo -e "\nResposta inválida"
                    echo
                    continue
            esac
            else
                create_bk
                break
        fi
    done
            


}
def_var(){               
        if [ -n "$1" ] ; then
            eval "$2=\$1"
        else
            echo "$3"
            exit 1
        fi
    }
def_arg(){
    if [ $# -eq 1 ] && [ -f "$1" ] && [[ "$1" == *.enc ]]; then
        decrypt "$1"
    else
        skip=false
        for arg in "$@"; do
            if $skip; then
                def_var $arg "${param[@]}"
                skip=false
                continue
            fi
            case $arg in
                "-d")
                    local param=("PATH_BK" "Detório não definido")
                    skip=true
                ;;

                "-o")
                    local param=("OUT_DIR" "Nome do arquivo de backup não definido!")
                    skip=true
                ;;

                *)
                    echo "Argumentos inválidos!"
                    exit 1
                ;;
            esac
        done

        NAME_BK=$(date +%Y%m%d_%H%M%S)
        SIZE_PATH=$(du -sb --exclude="$OUT_DIR/*.tar.gz.enc" "$PATH_BK" | cut -f1)
        SIZE_PATH=$((SIZE_PATH * 50 / 100))
    fi
}

dif_date_in_days() {
    local pass=true
    local LIST_FILES=$(ls "$OUT_DIR"/*.tar.gz.enc 2>/dev/null)
    for file in $LIST_FILES; do
        local DATE_MOD=$(stat -c %Y "$file")
        local DATE_NOW=$(date +%s)
        local DIF_DATE=$(( (DATE_NOW - DATE_MOD) / 86400 ))
        if [ $DIF_DATE -lt $DEFAULT_DAYS ] && $pass; then
            RECENT_BK="$file"
            pass=false
        elif [ -f $RECENT_BK ] && [ $DATE_MOD -gt $(stat -c %Y "$RECENT_BK") ]; then
            RECENT_BK="$file"
        fi

    done
}

progress_bar() {
    local width=50
    local percent=$1
    local completed=$((width * percent / 100))

    printf "["
    for ((i = 0; i < completed; i++)); do
        printf "#"
    done
    for ((i = completed; i < width; i++)); do
        printf " "
    done
    printf "] %d%%\r" $percent
}

create_bk(){
    echo "Tamanho estimado: $((SIZE_PATH / 1024))MB"
    echo -n "Digite a senha que será utilizada para criptografar o arquivo:"
    read -s PASSWD < /dev/tty
    echo -e "\nCriando backup..."
    echo
    tar czf "$OUT_DIR/$NAME_BK.tar.gz" --exclude="$OUT_DIR/*.tar.gz.enc" "$PATH_BK" 2>/dev/null & pid=$!
    sleep 1
    while lsof "$OUT_DIR/$NAME_BK.tar.gz" >/dev/null; do
        local size_now=$(du -b "$OUT_DIR/$NAME_BK.tar.gz" | cut -f1)
        local percent=$((size_now * 100 / SIZE_PATH))
        progress_bar $percent
        sleep .5
    done
    openssl enc -e -aes256 -iter 100000 -in "$OUT_DIR/$NAME_BK.tar.gz" -out "$OUT_DIR/$NAME_BK.tar.gz.enc" -k "$PASSWD" || { echo "Erro ao criptografar o arquivo"; exit 1; }
    rm -f "$OUT_DIR/$NAME_BK.tar.gz"
    echo "Backup concluído!"
    exit 0
}

decrypt(){
    echo -n "Digite a senha para descriptografar o arquivo:"
    read -s PASSWD < /dev/tty
    local output_file="${1%.enc}"
    openssl enc -d -aes256 -iter 100000 -in "$1" -out $output_file -k "$PASSWD" || { echo "Erro ao descriptografar o arquivo";rm -f $output_file; exit 1; }
    echo
    echo "Arquivo descriptografado com sucesso!"
    exit 0
}

help(){
    echo "          @Autor:         Paulo Mendonça"
    echo "          @Description:   O script têm o intuito de criar backups personalizados de forma segura utilizando"
    echo "                          criptografia OPENSSL."
    echo "                          Também é possível descriptografar por meio da senha, arquivos de backup."
    echo "          @Contact:       paulo.amadeu18@gmail || paulo.mendonca@sou.ufmt.br"

    echo
    echo "Execute ~\$$0 [opções] [argumentos] para iniciar o script."
    echo
    echo "Opções:   [-d] diretório  -   Define o diretório padrão do backup."
    echo "                              Caso não seja definido será utilizado o diretório home do usuário executor como padrão."
    echo "          [-o] diretório  -   Define o diretório destino do arquivo de backup criptografado."
    echo "                              Caso não seja definido será utilizado o diretório atual do bash."
    echo
    echo "          [{arquivo}.enc] -   Descriptografar aquivo .enc através da senha."
    echo
    exit 0
}

if [ $# -eq 1 ] && { [ $1 = "--help" ] || [ $1 = "-h" ]; }; then
    help
else
    main $@
fi