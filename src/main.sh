#!/bin/bash


#condicao de execucao ---------------------------------------------------------
condition=0
#------------------------------------------------------------------------------
# Verificar se é root
if [ $(id -u) -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    ((condition++))
fi
#------------------------------------------------------------------------------
#instala dependencias 
apt install nano -y
apt install curl -y
apt install openssh-server -y
#------------------------------------------------------------------------------
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

# Menu principal --------------------------------------------------------------
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

# Menu SSH --------------------------------------------------------------------
menussh() {
    echo "         -- MENU CONFIGURAR SSH -- "
    echo
    statusssh
    echo
    echo " 1- Desativar/Ativar SSH"
    echo " 2- Recaregar o serviço SSH"
    echo " 3- Reiniciar o serviço SSH"
    echo " 4- Abrir arquivo de configuração do SSH"
    echo " 5- Abrir pasta de chaves de criptografia"
    echo " 6- Gerar Chave de criptografia"
    echo " 0- Página anterior"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenussh $user_option
    
}

# Menu IP ---------------------------------------------------------------------
menuip() {
    echo "         -- MENU CONFIGURAR IP -- "
    echo
    statusip
    echo
    echo " 1- Desativar/Ativar interface de rede"
    echo " 2- Modificar Conexão DCHP/STATIC"
    echo " 3- Modificar Configuracoes de rede"
    echo " 4- Modificar DNS"
    echo " 5- Abrir Arquivo de Configuração de Rede"
    echo " 6- Reiniciar serviços de rede"
    echo " 0- Página anterior"
    echo
    read -p " Escolha uma opção: " user_option
    optionmenuip $user_option
}
# check status SSH ------------------------------------------------------------
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

# check status IP -------------------------------------------------------------
statusip() {

    # Identificar a interface de rede ativa (não loopback)
interface_ativa=$(ip -4 addr show | awk '/inet/ && !/127.0.0.1/ {print $NF}' | head -n 1)

# Verificar se a interface está ativa
if ip link show "$interface_ativa" | grep -q "state UP"; then
    echo " Interface ativa: $interface_ativa "

    # Capturar o IP local e a máscara de sub-rede
    ip_local=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f1)
    netmask=$(ip -4 addr show "$interface_ativa" | awk '/inet / {print $2}' | cut -d/ -f2)
    echo " IP Local: ${ip_local:-Não configurado} "
    echo " Máscara de Sub-rede: ${netmask:-Não configurada} "

    # Obter o IP público (externo)
    ip_publico=$(curl -s https://ipv4.icanhazip.com)
    echo " IP Público: ${ip_publico:-Não disponível} "

    # Verificar se a interface está configurada com DHCP ou IP estático
    if grep -q "iface $interface_ativa inet static" /etc/network/interfaces 2>/dev/null; then
        echo " Configuração: Estática "
    else
        echo " Configuração: DHCP "
    fi

    # Capturar o Gateway, verificando se ele está configurado
    gateway=$(awk "/iface $interface_ativa inet static/,/gateway/" /etc/network/interfaces | grep -i "gateway" | awk '{print $2}')
    if [ -z "$gateway" ]; then
        gateway="Não configurado"
    fi
    echo " Gateway: $gateway "

    # Capturar os servidores DNS, verificando se estão configurados
    dns1=$(awk "/iface $interface_ativa inet static/,/dns-nameservers/" /etc/network/interfaces | grep -i "dns-nameservers" | awk '{print $2}' | cut -d' ' -f1)
    dns2=$(awk "/iface $interface_ativa inet static/,/dns-nameservers/" /etc/network/interfaces | grep -i "dns-nameservers" | awk '{print $2}' | cut -d' ' -f2)

    if [ -z "$dns1" ]; then
        dns1="Não configurado"
    fi
    if [ -z "$dns2" ]; then
        dns2="Não configurado"
    fi

    echo " DNS 1: $dns1 "
    echo " DNS 2: $dns2 "

else
    logo
    echo " Interface $interface_ativa não está ativa. "
fi


}
# Lógica de opções ------------------------------------------------------------
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
        ((condition--))
        clear
        ;;
    *)
        logo
        echo "Opção inválida!"
        sleep 2
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
        systemctl reload ssh
        logo
        menussh
        ;;
    3)  
        if ! systemctl is-active --quiet sshd; then
            # Se o SSH estiver ativo, recarrega o serviço
            systemctl restart ssh
        else
            # Se o SSH não estiver ativo, informa ao usuário
            echo "SSH: está ativo"
            echo "Se estiver em uma conexão SSH, você será desconectado"
            read -p "Deseja reiniciar mesmo assim [y/n]? " useropt
            
            # Verifica se a resposta do usuário foi 'y' ou 'Y'
            if [ "$useropt" = "y" ] || [ "$useropt" = "Y" ]; then
                systemctl restart ssh
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
        logo
        menussh
        ;;
    4)
        nano /etc/ssh/sshd_config
        logo
        menussh
        ;;
    5)
        # Obtém o diretório onde o script está localizado
        script_dir=$(dirname "$(readlink -f "$0")")

        # Caminho absoluto da pasta "keys"
        keys_dir="$script_dir/keys"

        # Verifica se a pasta "keys" existe
        if [ ! -d "$keys_dir" ]; then
            mkdir -p "$keys_dir"
        fi

        # Garante que todas as operações subsequentes usem o diretório correto sem mudar o contexto do script
        cd "$keys_dir" || exit 1

        # Exibe o conteúdo do diretório
        ls -l
        echo "Caminho para a pasta keys: $keys_dir"

        # Espera 5 segundos
        sleep 5

        # Volta para o diretório inicial (opcional, para evitar problemas futuros)
        cd "$script_dir"

        # Exibe o logo e o menu
        logo
        menussh
        ;;
    6)  
        # Obtém o diretório onde o script está localizado
        script_dir=$(dirname "$(readlink -f "$0")")

        # Caminho absoluto da pasta "keys"
        keys_dir="$script_dir/keys"

        # Verifica se a pasta "keys" existe
        if [ ! -d "$keys_dir" ]; then
            mkdir -p "$keys_dir"
        fi

        # Sempre utiliza o caminho absoluto para evitar recursão
        logo

        # Menu de seleção de bits
        echo " Quantos bits será sua chave?"
        echo " 1- 1024"
        echo " 2- 2048"
        echo " 3- 4096"
        read -p " Escolha uma opção: " user_option

        # Valida a entrada do usuário
        case $user_option in
        1)
            ssh-keygen -t rsa -b 1024 -f "$keys_dir/id_rsa" -N ""
            ;;
        2)
            ssh-keygen -t rsa -b 2048 -f "$keys_dir/id_rsa" -N ""
            ;;
        3)
            ssh-keygen -t rsa -b 4096 -f "$keys_dir/id_rsa" -N ""
            ;;
        *)
            logo
            echo "Opção inválida! Por favor, escolha 1, 2 ou 3."
            sleep 3
            logo
            menussh
            ;;
        esac

        # Exibe o conteúdo da pasta de chaves
        echo "Chaves criadas no diretório: $keys_dir"
        ls -l "$keys_dir"

        # Exibe o logo e o menu
        sleep 5
        logo
        menussh
        ;;
    0)
        logo
        menu
        ;;
    *)
        logo
        echo "Opção inválida!"
        sleep 3
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
        # Caminho do arquivo de configuração
        config_file="/etc/network/interfaces"

        # Faz backup do arquivo original
        cp "$config_file" "${config_file}.bak"
        echo "Backup criado: ${config_file}.bak"

        # Verifica se o arquivo contém "inet dhcp" ou "inet static"
        if grep -q "inet dhcp" "$config_file"; then
            echo "Alternando para configuração estática (static)..."
            sed -i 's/inet dhcp/inet static/' "$config_file"
        elif grep -q "inet static" "$config_file"; then
            echo "Alternando para configuração dinâmica (dhcp)..."
            sed -i 's/inet static/inet dhcp/' "$config_file"
        else
            echo "Nenhuma configuração de 'inet' encontrada no arquivo."
            exit 1
        fi

        echo "Alteração concluída. Verifique o arquivo: $config_file"

        logo
        menuip
        ;;
    3)
        # Caminho do arquivo de configuração
        config_file="/etc/network/interfaces"

        # Faz backup do arquivo original
        cp "$config_file" "${config_file}.bak"

        # Localiza a seção "The primary network interface"
        if ! grep -q "# The primary network interface" "$config_file"; then
            echo " Seção 'The primary network interface' não encontrada. Abortando."
            menuip
        fi

        # Identifica a interface configurada na seção
        interface=$(awk '/# The primary network interface/{getline; print $2}' "$config_file")

        # Confirma a interface
        if [ -z "$interface" ]; then
            echo " Não foi possível determinar a interface. Verifique o arquivo de configuração."
            menuip
        fi

        # Solicita os novos valores diretamente
        logo
        echo " Digite o novo endereço IP:"
        read new_address

        echo " Digite a nova máscara de rede:"
        read new_netmask

        echo " Digite o novo gateway:"
        read new_gateway

        # Substitui ou adiciona as configurações no arquivo
        awk -v iface="$interface" -v addr="$new_address" -v mask="$new_netmask" -v gate="$new_gateway" '
        BEGIN {found=0}
        # Localiza a seção e marca como encontrada
        /# The primary network interface/ {found=1; print; next}
        found && $0 ~ "iface "iface {print; next}
        found && $0 ~ "address" {seen_address=1; print "    address " addr; next}
        found && $0 ~ "netmask" {seen_netmask=1; print "    netmask " mask; next}
        found && $0 ~ "gateway" {seen_gateway=1; print "    gateway " gate; next}
        {print}
        END {
            # Adiciona os campos que não foram encontrados
            if (found) {
                if (!seen_address) print "    address " addr
                if (!seen_netmask) print "    netmask " mask
                if (!seen_gateway) print "    gateway " gate
            }
        }' "$config_file" > "${config_file}.tmp"

        # Pergunta se deseja salvar as alterações
        logo
        echo " Deseja salvar as alterações? (Y/N)"
        read confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Salva as alterações
            mv "${config_file}.tmp" "$config_file"
            echo " Configurações aplicadas com sucesso!"
            sleep 3
        else
            # Desfaz as alterações
            rm "${config_file}.tmp"
            cp "${config_file}.bak" "$config_file"
            echo " Alterações descartadas."
            sleep 3
        fi
        logo
        menuip
        ;;
    4)

# Caminhos dos arquivos de configuração
resolv_file="/etc/resolv.conf"
interfaces_file="/etc/network/interfaces"

# Faz backup dos arquivos originais
cp "$resolv_file" "${resolv_file}.bak"
cp "$interfaces_file" "${interfaces_file}.bak"

# Solicita dois novos endereços DNS ao usuário
echo "Digite o primeiro endereço de DNS:"
read -r dns1

echo "Digite o segundo endereço de DNS:"
read -r dns2

# Atualiza o arquivo resolv.conf
> "$resolv_file"  # Limpa o conteúdo do arquivo
echo "nameserver $dns1" >> "$resolv_file"
echo "nameserver $dns2" >> "$resolv_file"

# Atualiza o arquivo interfaces
if grep -q "dns-nameservers" "$interfaces_file"; then
    # Atualiza a linha existente de dns-nameservers
    sed -i "s/^.*dns-nameservers.*/\tdns-nameservers $dns1 $dns2/" "$interfaces_file"
else
    # Adiciona nova configuração de DNS se não existir
    echo -e "\ndns-nameservers $dns1 $dns2" >> "$interfaces_file"
fi

# Pergunta ao usuário se deseja salvar as alterações
echo -e "\nDeseja salvar as alterações nos arquivos? (Y/N)"
read -r resposta

if [[ "$resposta" == "Y" || "$resposta" == "y" ]]; then
    echo "Alterações salvas com sucesso."
else
    # Restaura os backups originais
    mv "${resolv_file}.bak" "$resolv_file"
    mv "${interfaces_file}.bak" "$interfaces_file"
    echo "Alterações descartadas. Arquivos restaurados a partir dos backups."
fi


        logo
        menuip
        ;;
    5)
        nano /etc/network/interfaces
        logo
        menuip
        ;;
    6)
        logo
        systemctl restart networking.service
        echo " Interfaces de redes reiniciada"
        sleep 3
        logo
        menuip
        ;;
    0)
        logo
        menu
        ;;
    *)
        logo
        echo " Opção inválida!"
        sleep 3
        logo
        menuip
        ;;
    esac
}

# Loop principal de execucao --------------------------------------------------

while [ $condition -lt 1 ] && [ $condition -ge 0 ];
do
    logo            # Exibe o logo
    menu            # Exibe o menu
done
# captura de erro -------------------------------------------------------------
if [ $condition -ge 1 ]; then
    logo
    echo " Foram encontrados $condition erro(s) na execução da aplicação."
    echo
fi