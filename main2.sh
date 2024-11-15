#!/bin/bash

# Condição de execução -------------------------------------------------------
condition=true
-------------------------------------------------------------------------------

# Logo ------------------------------------------------------------------------
logo() {
    clear
    echo "  ___ ___ _  _   __  __   _   _  _   _   ___ ___ ___   "
    echo " / __/ __| || | |  \/  | /_\ | \| | /_\ / __| __| _ \\ "
    echo " \__ \__ \ __ | | |\/| |/ _ \| .  |/ _ \ (_ | _||   /  "
    echo " |___/___/_||_| |_|  |_/_/ \_\_|\_/_/ \_\___|___|_|_\\ "
    echo "                                           V1.0 beta"
    echo " "
}

# Verificar se é root --------------------------------------------------------
if [ $(id -u) -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    condition=false
fi

# Check status SSH -----------------------------------------------------------
statusssh() {
    if systemctl is-active --quiet sshd; then
        echo "SSH: está ativo"
    else
        echo "SSH: não está ativo"
    fi
    echo "IP Local: $(ip -4 addr show | awk '!/127.0.0.1/ && /inet/ {print $2}' | cut -d/ -f1)"
}

# Check status IP ------------------------------------------------------------
statusip() {
    # Função para capturar as configurações de uma interface
    get_network_info() {
        local interface=$1

        # Verificar se a interface está configurada para IP estático
        if grep -q "iface $interface inet static" /etc/network/interfaces; then
            echo " Interface: $interface"

            # Capturar o Gateway
            gateway=$(grep -A 1 "iface $interface inet static" /etc/network/interfaces | grep -i "gateway" | awk '{print $2}')
            if [ ! -z "$gateway" ]; then
                echo " Gateway: $gateway"
            else
                echo " Gateway: Não configurado"
            fi

            # Capturar os servidores DNS
            dns=$(grep -A 1 "iface $interface inet static" /etc/network/interfaces | grep -i "dns-nameservers" | awk '{print $2}')
            if [ ! -z "$dns" ]; then
                echo " DNS: $dns"
            else
                echo " DNS: Não configurado"
            fi

            echo # Linha em branco entre interfaces
        fi
    }

    # Loop para todas as interfaces de rede
    for interface in $(ls /sys/class/net); do
        get_network_info $interface
    done
}

# Menu principal --------------------------------------------------------------
menu() {
    echo "         -- MENU -- "
    echo " 1- Configurar serviço SSH"
    echo " 2- Configurar IP da Máquina"
    echo " 0- Sair"
    echo " "
    read -p " Escolha uma opção: " user_option
    optionmenu $user_option
}

# Menu SSH -------------------------------------------------------------------
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

# Menu IP --------------------------------------------------------------------
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

# Lógica de opções -----------------------------------------------------------
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

# Opções do Menu SSH --------------------------------------------------------
optionmenussh() {
    case $1 in
    1)
        if systemctl is-active --quiet sshd; then
            systemctl stop sshd
        else
            systemctl start sshd
        fi
        logo
        menussh
        ;;
    2)
        echo "Alterando configuração de login do root"
        # Modificar SSH para permitir ou não login como root
        sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
        systemctl restart sshd
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
    8)
        ssh-keygen -t rsa -b 2048
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

# Opções do Menu IP ---------------------------------------------------------
optionmenuip() {
    case $1 in
    1)
        read -p "Digite o nome da interface (ex: eth0, enp0s3): " interface
        ip link set $interface down
        ip link set $interface up
        logo
        menuip
        ;;
    2)
        read -p "Digite o nome da interface (ex: eth0, enp0s3): " interface
        read -p "Escolha [dhcp/static]: " mode
        if [ "$mode" == "static" ]; then
            nano /etc/network/interfaces
        else
            # Configuração DHCP
            sed -i "/iface $interface inet/static/c\iface $interface inet dhcp" /etc/network/interfaces
        fi
        systemctl restart networking
        logo
        menuip
        ;;
    3)
        read -p "Digite o nome da interface (ex: eth0, enp0s3): " interface
        read -p "Digite o novo IP: " ip
        sed -i "/iface $interface inet static/c\iface $interface inet static\naddress $ip" /etc/network/interfaces
        systemctl restart networking
        logo
        menuip
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

# Loop principal ------------------------------------------------------------
while $condition
do
    logo            # Exibe o logo
    menu            # Exibe o menu
done
