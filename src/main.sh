#!/bin/bash

# Verificar se é root
if [ $(id -u) -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    condition=false
fi

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
    echo
}

# Menu principal ----------------------------------------------------------
menu() {
    echo "         -- MENU -- "
    echo
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
    echo
    statusssh
    echo
    echo " 1- Desativar/Ativar SSH"
    echo " 2- Modificar Root Login"
    echo " 3- Adicionar Grupo"
    echo " 4- Remover Grupo"
    echo " 5- Reiniciar o serviço SSH"
    echo " 6- Abrir arquivo de configuração do SSH"
    echo " 7- Abrir pasta de chaves de criptografia"
    echo " 8- Gerar Chave de criptografia"
    echo " 0- Página anterior"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenussh $user_option
}

# Menu IP ------------------------------------------------------------------
menuip() {
    echo "         -- MENU CONFIGURAR IP -- "
    echo
    statusip
    echo " "
    echo " 1- Desativar/Ativar interface de rede"
    echo " 2- Modificar Conexão DCHP/STATIC"
    echo " 3- Modificar IP"
    echo " 4- Modificar Máscara de Rede"
    echo " 5- Modificar Gateway"
    echo " 6- Modificar DNS 1"
    echo " 7- Modificar DNS 2"
    echo " 8- Abrir Arquivo de Configuração de Rede"
    echo " 0- Página anterior"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenuip $user_option
}
# check status SSH --------------------------------------------------------
statusssh() {
    statusip
    echo
    #check 
    if systemctl is-active --quiet sshd; then
            echo " SSH: está ativo"
        else
            echo " SSH: não está ativo"
        fi

}

# check status IP ---------------------------------------------------------
statusip() {

    # Identifica a interface de rede ativa (não loopback)
    interface_ativa=$(ip -4 addr | awk '/inet/ && !/127.0.0.1/ {print $NF}' | head -n 1)

    # Verifica se a interface está ativa
    if ip link show "$interface_ativa" | grep -q "state UP"; then
        echo " Interface ativa: $interface_ativa "  # Adicionando espaço

        # Captura o IP local e a máscara de sub-rede
        ip_local=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f1)
        netmask=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f2)
        echo " IP Local: ${ip_local:-Não configurado} "  # Adicionando espaço
        echo " Máscara de Sub-rede: ${netmask:-Não configurada} "  # Adicionando espaço

        # Obtendo o IP público (externo)
        ip_publico=$(curl -s https://ipv4.icanhazip.com)  # Corrigido para capturar o IP público IPv4

        echo " IP Público: ${ip_publico:-Não disponível} "  # Adicionando espaço

        # Pega o tipo de configuração (DHCP ou Estático)
        if grep -q "iface $interface_ativa inet static" /etc/network/interfaces 2>/dev/null; then
            echo " Configuração: Static "
        else
            echo " Configuração: DHCP "
        fi

        # Captura o Gateway
        gateway=$(awk "/iface $interface_ativa inet static/,/gateway/" /etc/network/interfaces | grep -i "gateway" | awk '{print $2}')
        echo " Gateway: ${gateway:-Não configurado} "

        # Captura os servidores DNS
        dns1=$(awk "/iface $interface_ativa inet static/,/dns-nameservers/" /etc/network/interfaces | grep -i "dns-nameservers" | awk '{print $2}' | cut -d' ' -f1)
        dns2=$(awk "/iface $interface_ativa inet static/,/dns-nameservers/" /etc/network/interfaces | grep -i "dns-nameservers" | awk '{print $2}' | cut -d' ' -f2)
        echo " DNS 1: ${dns1:-Não configurado} "
        echo " DNS 2: ${dns2:-Não configurado} "
        
    else
        echo " Interface $interface_ativa não está ativa. "
    fi

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
    10)
        apt install curl -y
        clear
        timeout 15s curl ascii.live/rick
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
        if systemctl is-active --quiet sshd; then
            # Se o SSH estiver ativo, recarrega o serviço
            /etc/init.d/ssh restart
        else
            # Se o SSH não estiver ativo, informa ao usuário
            echo "SSH: não está ativo"
            echo "Se estiver em uma conexão SSH, você será desconectado"
            read -p "Deseja reiniciar mesmo assim [y/n]? " useropt
            
            # Verifica se a resposta do usuário foi 'y' ou 'Y'
            if [ "$useropt" = "y" ] || [ "$useropt" = "Y" ]; then
                /etc/init.d/ssh restart
                logo
                menussh
            # Verifica se a resposta do usuário foi 'n' ou 'N'
            elif [ "$useropt" = "n" ] || [ "$useropt" = "N" ]; then
                logo
                menussh
            else
                # Caso a opção seja inválida
                echo "Opção inválida"
                logo
                menussh
            fi
        fi
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
        clear
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
    8)
        clear
        nano /etc/network/interfaces
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

# Loop principal -----------------------------------------------------------

while $condition
do
    logo            # Exibe o logo
    menu            # Exibe o menu
done