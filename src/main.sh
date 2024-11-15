#!/bin/bash

#logo -------------------------------------------------------------------------

logo() {
    echo "  ___ ___ _  _   __  __   _   _  _   _   ___ ___ ___   "
    echo " / __/ __| || | |  \/  | /_\ | \| | /_\ / __| __| _ \\ "
    echo " \__ \__ \ __ | | |\/| |/ _ \| .  |/ _ \ (_ | _||   /  "
    echo " |___/___/_||_| |_|  |_/_/ \_\_|\_/_/ \_\___|___|_|_\\ "
    echo "V1.0 beta"
}

#check instaler ---------------------------------------------------------------

#display ----------------------------------------------------------------------

menu() {
    echo "         -- MENU -- "
    echo "1- Configurar serviço SSH"
    echo "2- Configurar IP da Maquina"
    echo "0- Sair"
}

#menu ssh

statusssh() {
    #aqui vem a magica do status
}
menussh() {
    echo "         -- MENU SSH -- "
    echo " "
    statusssh
    echo " "
    echo "1- Desativar/Ativar SSH"
    echo "2- Modificar Root Login"
    echo "3- Adicionar Grupo"
    echo "4- Remover Grupo"
    echo "5- Reiniciar o serviço SSH"
    echo "6- Abrir arquivo configuracao do SSH"
    echo "7- Abrir pasta de chaves de criptografia"
    echo "8- Gerar Chave de criptografia"
    echo "0- Página anterior"
}

#menu ip

statusip() {
    #aqui vem a magica do status
}
menuip() {
    echo "         -- MENU IP -- "
    echo " "
    statusip
    echo " "
    echo "1- Desativar/Ativar interface de rede"
    echo "2- Modificar Conexão DCHP/STATIC"
    echo "3- Modificar IP"
    echo "4- Modificar Mascara de rede"
    echo "5- Modificar Gateway"
    echo "6- Modificar DNS 1"
    echo "7- Modificar DNS 2"
    echo "0- Página anterior"
}

#logical ----------------------------------------------------------------------
optionmenu() {
    case $1 in
    1)
        echo "Status do serviço SSH"
        menussh
        ;;
    2)
        echo "Mudar IP da máquina"
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
        echo "Status do serviço SSH"
        # Adicione os comandos para verificar o status do SSH, se necessário.
        ;;
    2)
        echo "Mudar IP da máquina"
        # Adicione comandos para mudar o IP da máquina, se necessário.
        ;;
    3)
        echo "Configurar SSH"
        # Adicione os comandos para configurar o SSH, se necessário.
        ;;
    4)
        echo "Opção 4 selecionada"
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

optionmenuip() {
    case $1 in
    1)
        echo "Status do serviço SSH"
        # Adicione os comandos para verificar o status do SSH, se necessário.
        ;;
    2)
        echo "Mudar IP da máquina"
        # Adicione comandos para mudar o IP da máquina, se necessário.
        ;;
    3)
        echo "Configurar SSH"
        # Adicione os comandos para configurar o SSH, se necessário.
        ;;
    4)
        echo "Opção 4 selecionada"
        ;;
    5)
        echo "Opção 5 selecionada"
        ;;
    6)
        echo "Opção 6 selecionada"
        ;;
    7)
        echo "Opção 7 selecionada"
        ;;
    8)
        echo "Opção 8 selecionada"
        ;;
    9)
        echo "Opção 9 selecionada"
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

# Laço principal --------------------------------------------------------------
condition=true
while [ $condition ]; do 
    logo
    menu
    read -p "Escolha uma opção: " user_option  # A função read agora salva a opção do usuário na variável user_option
    optionmenu $user_option  # Passa o valor de user_option para a função option
done
