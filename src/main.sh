#!/bin/bash

echo "  ___ ___ _  _   __  __   _   _  _   _   ___ ___ ___   "
echo " / __/ __| || | |  \/  | /_\ | \| | /_\ / __| __| _ \\ "
echo " \__ \__ \ __ | | |\/| |/ _ \| .  |/ _ \ (_ | _||   /  "
echo " |___/___/_||_| |_|  |_/_/ \_\_|\_/_/ \_\___|___|_|_\\ "

condition=true
while [condition]; do 
    menu
    read option

    done

menu() {
    echo "-- Status SSH: "
    echo "1- Status do serviço SSH"
    echo "2- Mudar IP da Maquina"
    echo "3- Configurar SSH"
    echo "4- "
    echo "5- "
    echo "6- "
    echo "7- "
    echo "8- "
    echo "9- "
    echo "0- sair"
}

option(option) {
    case $option in
    1);;
    2);;
    3);;
    4);;
    5);;
    6);;
    7);;
    8);;
    9);;
    0)condition=false;;
    *)echo "Opçao inválida!";;
}