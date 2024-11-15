#!/bin/bash

# logo ----------------------------------------------------------------------
logo() {
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
    exit 1
fi

# check status SSH --------------------------------------------------------
statusssh() {
    echo "Status SSH: " systemctl is-active --quiet sshd && echo "Ativo" || echo "Inativo"
}

# check status IP ---------------------------------------------------------
statusip() {
    ip a | grep inet6
}

# Menu principal ----------------------------------------------------------
menu() {
    echo "         -- MENU -- "
    echo " 1- Configurar serviço SSH"
    echo " 2- Configurar IP da Máquina"
    echo " 0- Sair"
}

# Menu SSH -----------------------------------------------------------------
menussh() {
    echo "         -- MENU SSH -- "
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
}

# Menu IP ------------------------------------------------------------------
menuip() {
    echo "         -- MENU IP -- "
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
}

# Lógica de opções ---------------------------------------------------------
optionmenu() {
    case $1 in
    1)
        echo "Configurando serviço SSH"
        clear
        logo
        menussh
        ;;
    2)
        echo "Configurando IP da máquina"
        clear
        logo
        menuip
        ;;
    0)
        condition=false
        echo "Saindo..."
        ;;
    *)
        echo "Opção inválida!"
        ;;
    esac
}

optionmenussh() {
    case $1 in
    1)
        echo "Desativando/Ativando o serviço SSH"
        systemctl restart sshd
        ;;
    2)
        echo "Modificando Root Login"
        # Comando para modificar root login
        ;;
    3)
        echo "Adicionando Grupo"
        # Comando para adicionar grupo
        ;;
    0)
        condition=true
        main_menu
        ;;
    *)
        echo "Opção inválida!"
        ;;
    esac
}

optionmenuip() {
    case $1 in
    1)
        echo "Desativando/Ativando interface de rede"
        # Comando para ativar/desativar interface
        ;;
    0)
        condition=true
        main_menu
        ;;
    *)
        echo "Opção inválida!"
        ;;
    esac
}

# Loop principal -----------------------------------------------------------
condition=true
main_menu() {
    logo
    menu
    read -p "Escolha uma opção: " user_option
    optionmenu $user_option
}

main_menu
