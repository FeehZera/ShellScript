#!/bin/bash

# Condição de execução ------------------------------------------------------
condition=0

# Verificar se é root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    ((condition++))
    exit 1
fi

# Instalar dependências
apt update -y
apt install -y nano curl openssh-server

# Função logo
logo() {
    clear
    echo "  ___ ___ _  _   __  __   _   _  _   _   ___ ___ ___   "
    echo " / __/ __| || | |  \/  | /_\ | \| | /_\ / __| __| _ \\ "
    echo " \__ \__ \ __ | | |\/| |/ _ \| .  |/ _ \ (_ | _||   /  "
    echo " |___/___/_||_| |_|  |_/_/ \_\_|\_/_/ \_\___|___|_|_\\ "
    echo "                                           V1.0 beta"
    echo
}

# Função de exibição de status SSH
statusssh() {
    if systemctl is-active --quiet sshd; then
        echo " SSH: está ativo"
    else
        echo " SSH: não está ativo"
    fi
}

# Função de exibição de status IP
statusip() {
    interface_ativa=$(ip -4 addr | awk '/inet/ && !/127.0.0.1/ {print $NF}' | head -n 1)

    if ip link show "$interface_ativa" | grep -q "state UP"; then
        ip_local=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f1)
        netmask=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f2)
        ip_publico=$(curl -s https://ipv4.icanhazip.com)

        echo " Interface ativa: $interface_ativa"
        echo " IP Local: ${ip_local:-Não configurado}"
        echo " Máscara de Sub-rede: ${netmask:-Não configurada}"
        echo " IP Público: ${ip_publico:-Não disponível}"

        if grep -q "iface $interface_ativa inet static" /etc/network/interfaces 2>/dev/null; then
            echo " Configuração: Static"
        else
            echo " Configuração: DHCP"
        fi

        gateway=$(ip route | grep -m 1 default | awk '{print $3}')
        echo " Gateway: ${gateway:-Não configurado}"

        dns1=$(grep -i "nameserver" /etc/resolv.conf | awk 'NR==1 {print $2}')
        dns2=$(grep -i "nameserver" /etc/resolv.conf | awk 'NR==2 {print $2}')
        echo " DNS 1: ${dns1:-Não configurado}"
        echo " DNS 2: ${dns2:-Não configurado}"

    else
        echo " Interface $interface_ativa não está ativa."
    fi
}

# Menu principal
menu() {
    logo
    echo "         -- MENU -- "
    echo
    echo " 1- Configurar serviço SSH"
    echo " 2- Configurar IP da Máquina"
    echo " 0- Sair"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenu $user_option
}

# Função de lógica de opções
optionmenu() {
    case $1 in
        1) menussh ;;
        2) menuip ;;
        0) exit 0 ;;
        *) logo; echo "Opção inválida!"; sleep 2; menu ;;
    esac
}

# Menu SSH
menussh() {
    logo
    statusssh
    echo
    echo " 1- Desativar/Ativar SSH"
    echo " 2- Recarregar o serviço SSH"
    echo " 3- Reiniciar o serviço SSH"
    echo " 4- Editar configuração SSH"
    echo " 5- Gerar Chave SSH"
    echo " 0- Voltar"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenussh $user_option
}

# Função de lógica de opções SSH
optionmenussh() {
    case $1 in
        1) systemctl is-active --quiet sshd && systemctl stop sshd || systemctl start sshd ;;
        2) systemctl reload ssh ;;
        3) systemctl restart ssh ;;
        4) nano /etc/ssh/sshd_config ;;
        5) gerar_chave_ssh ;;
        0) menu ;;
        *) logo; echo "Opção inválida!"; sleep 2; menussh ;;
    esac
}

# Função para gerar chave SSH
gerar_chave_ssh() {
    keys_dir="$HOME/.ssh"
    mkdir -p "$keys_dir"
    
    echo "Escolha o tamanho da chave:"
    echo "1- 1024 bits"
    echo "2- 2048 bits"
    echo "3- 4096 bits"
    read -p "Escolha uma opção: " bit_size

    case $bit_size in
        1) ssh-keygen -t rsa -b 1024 -f "$keys_dir/id_rsa" -N "" ;;
        2) ssh-keygen -t rsa -b 2048 -f "$keys_dir/id_rsa" -N "" ;;
        3) ssh-keygen -t rsa -b 4096 -f "$keys_dir/id_rsa" -N "" ;;
        *) echo "Opção inválida!"; gerar_chave_ssh ;;
    esac

    ls -l "$keys_dir"
    sleep 3
    menussh
}

# Menu de IP
menuip() {
    logo
    statusip
    echo
    echo " 1- Desativar/Ativar interface de rede"
    echo " 2- Alternar DHCP/Static"
    echo " 3- Modificar Configurações IP"
    echo " 4- Modificar DNS"
    echo " 0- Voltar"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenuip $user_option
}

# Função de lógica de opções de IP
optionmenuip() {
    case $1 in
        1) desativar_interface ;;
        2) alternar_dhcp_static ;;
        3) modificar_ip ;;
        4) modificar_dns ;;
        0) menu ;;
        *) logo; echo "Opção inválida!"; sleep 2; menuip ;;
    esac
}

# Função para desativar/ativar interface de rede
desativar_interface() {
    interface_ativa=$(ip -4 addr | awk '/inet/ && !/127.0.0.1/ {print $NF}' | head -n 1)
    
    if ip link show "$interface_ativa" | grep -q "state UP"; then
        ip link set "$interface_ativa" down
        echo "Interface $interface_ativa desativada."
    else
        ip link set "$interface_ativa" up
        echo "Interface $interface_ativa ativada."
    fi
    
    sleep 2
    menuip
}

# Função para alternar entre DHCP e Static
alternar_dhcp_static() {
    config_file="/etc/network/interfaces"
    cp "$config_file" "${config_file}.bak"
    
    if grep -q "inet dhcp" "$config_file"; then
        sed -i 's/inet dhcp/inet static/' "$config_file"
    else
        sed -i 's/inet static/inet dhcp/' "$config_file"
    fi
    
    echo "Configuração alterada. Verifique o arquivo: $config_file"
    menuip
}

# Função para modificar configurações IP
modificar_ip() {
    config_file="/etc/network/interfaces"
    cp "$config_file" "${config_file}.bak"

    echo "Digite o novo IP:"
    read ip
    echo "Digite a nova máscara de sub-rede:"
    read netmask
    echo "Digite o novo gateway:"
    read gateway

    awk -v ip="$ip" -v netmask="$netmask" -v gateway="$gateway" '
        /iface/ && !/loopback/ {print; next}
        /address/ {print "    address " ip; next}
        /netmask/ {print "    netmask " netmask; next}
        /gateway/ {print "    gateway " gateway; next}
        {print}
    ' "$config_file" > "${config_file}.tmp"

    mv "${config_file}.tmp" "$config_file"
    menuip
}

# Função para modificar DNS
modificar_dns() {
    resolv_file="/etc/resolv.conf"
    
    cp "$resolv_file" "${resolv_file}.bak"
    
    echo "Digite o primeiro servidor DNS:"
    read dns1
    echo "Digite o segundo servidor DNS:"
    read dns2
    
    echo -e "nameserver $dns1\nnameserver $dns2" > "$resolv_file"
    
    echo "DNS alterados com sucesso!"
    sleep 2
    menuip
}

# Chama o menu principal
menu
