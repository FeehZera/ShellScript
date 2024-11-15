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
            echo "SSH: está ativo"
        else
            echo "SSH: não está ativo"
        fi
    echo "IP Local: $(ip -4 addr show | awk '!/127.0.0.1/ && /inet/ {print $2}' | cut -d/ -f1)"

}

# check status IP ---------------------------------------------------------
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
        if systemctl is-active --quiet sshd; then
            # Se o SSH estiver ativo, recarrega o serviço
            /etc/init.d/ssh reload
        else
            # Se o SSH não estiver ativo, informa ao usuário
            echo "SSH: não está ativo"
            echo "Se estiver em uma conexão SSH, você será desconectado"
            read -p "Deseja reiniciar mesmo assim [y/n]? " useropt
            
            # Verifica se a resposta do usuário foi 'y' ou 'Y'
            if [ "$useropt" = "y" ] || [ "$useropt" = "Y" ]; then
                /etc/init.d/ssh reload
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