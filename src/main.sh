#!/bin/bash

#condicao de execucao ---------------------------------------------------------
condition=true
-------------------------------------------------------------------------------

# logo ------------------------------------------------------------------------
logo() {
    clear
    echo "  ___ ___ _  _   __  __   _   _  _   _   ___ ___ ___   "
    echo " / __/ __| || | |  \/  | /_\ | \| | /_\ / __| __| _ \\ "
    echo " \__ \__ \ __ | | |\/| |/ _ \| .  |/ _ \ (_ | _||   /  "
    echo " |___/___/_||_| |_|  |_/_/ \_\_|\_/_/ \_\___|___|_|_\\ "
    echo "                                           V1.0 beta"
    echo " "
}

# Verificar se é root
if [ $(id -u) -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    condition=false
fi

# check status SSH --------------------------------------------------------
statusssh() {
    if systemctl is-active --quiet sshd; then
            echo "O serviço SSH está ativo"
        else
            echo "O serviço SSH não está ativo"
        fi
    echo "IP Local: $(ip -4 addr show | awk '!/127.0.0.1/ && /inet/ {print $2}' | cut -d/ -f1)"

}

# check status IP ---------------------------------------------------------
statusip() {

    #ip local
    echo "IP Local: $(ip -4 addr show | awk '!/127.0.0.1/ && /inet/ {print $2}' | cut -d/ -f1)"

    #mascara de rede
    echo "Máscara de Rede: $(ip -4 addr show | awk '!/127.0.0.1/ && /inet/ {print $2}' | cut -d/ -f1 | xargs -I {} ipcalc -n {} | grep Netmask | awk '{print $2}')"
    
    #mostra se esta em dhcp ou estatico
    for interface in $(nmcli device status | awk '{if(NR>1) print $1}'); do
    echo "Interface: $interface"
    method=$(nmcli device show $interface | grep -i 'IP4.method' | awk '{print $2}')
    if [ "$method" == "auto" ]; then
        echo "Modo: DHCP"
    elif [ "$method" == "manual" ]; then
        echo "Modo: Static"
    else
        echo "Modo desconhecido"
    fi
    echo
    done



}

# Menu principal ----------------------------------------------------------
menu() {
    echo "         -- MENU -- "
    echo " 1- Configurar serviço SSH"
    echo " 2- Configurar IP da Máquina"
    echo " 0- Sair"
    echo " "
    read -p " Escolha uma opção: " user_option
    optionmenu $user_option
}

# Menu SSH -----------------------------------------------------------------
menussh() {
    echo "         -- MENU CONFIGURAR SSH -- "
    echo " "
    statusssh
    echo " "
    echo " 1- Desativar/Ativar SSH"
    echo " 2- Modificar Root Login"
    echo " 3- Adicionar Grupo"
    echo " 4- Remover Grupo"
    echo " 5- Reiniciar o serviço SSH"
    echo " 6- Abrir arquivo de configuração do SSH"
    echo " 7- Abrir pasta de chaves de criptografia"
    echo " 8- Gerar Chave de criptografia"
    echo " 0- Página anterior"
    echo " "
    read -p " Escolha uma opção: " user_option
    optionmenussh $user_option
}

# Menu IP ------------------------------------------------------------------
menuip() {
    echo "         -- MENU CONFIGURAR IP -- "
    echo " "
    statusip
    echo " "
    echo " 1- Desativar/Ativar interface de rede"
    echo " 2- Modificar Conexão DCHP/STATIC"
    echo " 3- Modificar IP"
    echo " 4- Modificar Máscara de Rede"
    echo " 5- Modificar Gateway"
    echo " 6- Modificar DNS 1"
    echo " 7- Modificar DNS 2"
    echo " 0- Página anterior"
    echo " "
    read -p " Escolha uma opção: " user_option
    optionmenuip $user_option
}

# Lógica de opções ---------------------------------------------------------
optionmenu() {
    case $1 in
    1)
        logo
        menussh
        ;;
    2)
        logo
        menuip
        ;;
    
    0)
        condition=false
        clear
        ;;
    *)
        echo "Opção inválida!"
        logo
        menu
        ;;
    esac
}

optionmenussh() {
    case $1 in
    1)
        if systemctl is-active --quiet sshd; then
            systemctl stop sshd # desativando
        else
            systemctl start sshd  # ativando
        fi
        logo
        menussh
        ;;
    2)
        logo
        menussh
        ;;
    3)
        logo
        menussh
        ;;
   
    4)
        logo
        menussh
        ;;
    5)
        systemctl restart sshd
        logo
        menussh
        ;;
    6)
        nano /etc/ssh/sshd_config
        logo
        menussh
        ;;
    7)
        logo
        menussh
        ;;
    8)  
        logo
        menussh
        ;;

    0)
        logo
        menu
        ;;
    *)
        echo "Opção inválida!"
        logo
        menussh
        ;;
    esac
}

optionmenuip() {
    case $1 in
    1)
        echo "Desativando/Ativando interface de rede"
        # Comando para ativar/desativar interface
        ;;
    2)
        clear
        ;;
    3)
        clear
        ;;
    4)
        clear
        ;;
    5)
        clear
        ;;
    6)
        clear
        ;;
    7)
        clear
        ;;
    0)
        logo
        menu
        ;;
    *)
        echo "Opção inválida!"
        logo
        menuip
        ;;
    esac
}

# Loop principal -----------------------------------------------------------

while $condition
do
    logo            # Exibe o logo
    menu            # Exibe o menu
done