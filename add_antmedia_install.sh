#!/bin/bash

# Atualiza o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instala dependências necessárias
echo "Instalando dependências..."
sudo apt install -y openjdk-11-jdk wget unzip nginx

# Baixa o Ant Media Server Community Edition
AMS_VERSION="ams-v2.12.0"
echo "Baixando o Ant Media Server Community Edition ($AMS_VERSION)..."
wget https://github.com/ant-media/Ant-Media-Server/releases/download/$AMS_VERSION/ant-media-server-$AMS_VERSION.zip

# Descompacta o arquivo
echo "Descompactando o Ant Media Server..."
unzip ant-media-server-$AMS_VERSION.zip
cd ant-media-server

# Instala o Ant Media Server
echo "Instalando o Ant Media Server..."
sudo ./install_ant-media-server.sh

# Função para configurar o domínio
configurar_dominio() {
  echo "Você deseja configurar um domínio? (sim/não)"
  read usar_dominio

  if [[ "$usar_dominio" == "sim" ]]; then
    echo "Digite o domínio que deseja usar (exemplo: seu-dominio.com):"
    read dominio

    # Configuração do NGINX
    echo "Configurando o domínio $dominio..."
    sudo tee /etc/nginx/sites-available/antmedia <<EOF
server {
    listen 80;
    server_name $dominio;

    location / {
        proxy_pass http://127.0.0.1:5080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # Habilita a configuração do NGINX
    sudo ln -s /etc/nginx/sites-available/antmedia /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx

    echo "Domínio configurado com sucesso: http://$dominio"
  else
    echo "Configuração de domínio ignorada. O Ant Media Server estará acessível via IP do servidor."
  fi
}

# Configura o domínio (opcional)
configurar_dominio

# Inicia o Ant Media Server
echo "Iniciando o Ant Media Server..."
sudo service antmedia start

# Verifica o status do Ant Media Server
sudo service antmedia status

# Finaliza
echo "Instalação concluída! Você pode acessar o Ant Media Server em:"
echo " - Pelo IP: http://<seu_ip>:5080"
echo " - Ou pelo domínio configurado (se aplicável)."
