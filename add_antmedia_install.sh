#!/bin/bash

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar o Java (necessário para o Ant Media Server)
echo "Instalando o Java Development Kit (JDK)..."
sudo apt install openjdk-11-jdk -y

# Baixar e instalar o Ant Media Server
echo "Baixando e instalando o Ant Media Server..."
wget https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh
sudo chmod +x install_ant-media-server.sh
sudo ./install_ant-media-server.sh -i

# Perguntar se vai usar um domínio
read -p "Você deseja usar um domínio para acessar o Ant Media Server (sim/não)? " DOMAIN_OPTION

if [[ "$DOMAIN_OPTION" == "sim" || "$DOMAIN_OPTION" == "SIM" ]]; then
    read -p "Digite o domínio que deseja usar (ex.: live.macbvendas.com.br): " DOMAIN
    echo "Você escolheu configurar o domínio $DOMAIN."
    echo "Certifique-se de configurar o seu servidor proxy reverso (Nginx, Apache, etc.) para apontar o domínio para a porta 5080 do Ant Media Server."
else
    # Usar IP público da VPS
    VPS_IP=$(curl -s http://checkip.amazonaws.com)
    echo "Você escolheu usar o IP público da VPS: $VPS_IP"
    echo "Certifique-se de configurar o seu servidor proxy reverso para apontar para o IP $VPS_IP na porta 5080."
fi

# Exibir informações finais
echo
echo "==================== INSTALAÇÃO CONCLUÍDA ===================="
if [[ "$DOMAIN_OPTION" == "sim" || "$DOMAIN_OPTION" == "SIM" ]]; then
    echo "Acesse o Ant Media Server no domínio configurado: http://$DOMAIN:5080"
else
    echo "Acesse o Ant Media Server no IP público: http://$VPS_IP:5080"
fi
echo "============================================================="
echo "IMPORTANTE: Certifique-se de configurar seu servidor proxy reverso para apontar para o Ant Media Server (porta 5080)."
