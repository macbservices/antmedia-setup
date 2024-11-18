#!/bin/bash

# Atualizando o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalando o Java (necessário para o Ant Media Server)
echo "Instalando o Java Development Kit (JDK)..."
sudo apt install openjdk-11-jdk -y

# Baixando e instalando o Ant Media Server
echo "Baixando e instalando o Ant Media Server..."
wget https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh
sudo chmod +x install_ant-media-server.sh
sudo ./install_ant-media-server.sh -i

# Perguntar se vai usar domínio
read -p "Você deseja usar um domínio (sim/não)? " DOMAIN_OPTION

if [[ "$DOMAIN_OPTION" == "sim" || "$DOMAIN_OPTION" == "SIM" ]]; then
    read -p "Digite o domínio que deseja usar (ex.: live.macbvendas.com.br): " DOMAIN
    echo "Você escolheu o domínio $DOMAIN"
    
    # Configurar o Nginx para o domínio
    echo "Instalando e configurando o Nginx..."
    sudo apt install nginx -y
    sudo tee /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:5080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # Ativar a configuração do Nginx
    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    
    # Testar a configuração do Nginx
    echo "Testando a configuração do Nginx..."
    sudo nginx -t

    # Reiniciar o Nginx
    echo "Reiniciando o Nginx..."
    sudo systemctl restart nginx

    # Instalar o Certbot e configurar SSL
    echo "Instalando o Certbot e configurando o SSL..."
    sudo apt install certbot python3-certbot-nginx -y
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN
    sudo systemctl restart nginx
else
    # Usar IP público da VPS
    VPS_IP=$(curl -s http://checkip.amazonaws.com)
    echo "Você escolheu usar o IP público da VPS: $VPS_IP"
    
    # Configuração do Nginx com IP
    echo "Instalando e configurando o Nginx para o IP $VPS_IP..."
    sudo apt install nginx -y
    sudo tee /etc/nginx/sites-available/antmedia <<EOF
server {
    listen 80;
    server_name $VPS_IP;

    location / {
        proxy_pass http://127.0.0.1:5080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # Ativar a configuração do Nginx
    sudo ln -s /etc/nginx/sites-available/antmedia /etc/nginx/sites-enabled/
    
    # Testar a configuração do Nginx
    echo "Testando a configuração do Nginx..."
    sudo nginx -t

    # Reiniciar o Nginx
    echo "Reiniciando o Nginx..."
    sudo systemctl restart nginx
fi

# Finalização da instalação
echo "Instalação do Ant Media Server concluída!"
echo "Se você usou o domínio, acesse https://$DOMAIN."
echo "Se usou o IP, acesse http://$VPS_IP."

# Instruções para abrir as portas no roteador
echo "Certifique-se de abrir as portas 80 e 443 no seu roteador e apontá-las para o IP da VPS."
