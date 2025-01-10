#!/bin/bash

# Função para configurar domínio
configurar_dominio() {
  echo "Você deseja usar um domínio? (sim/não)"
  read usar_dominio

  if [[ "$usar_dominio" == "sim" ]]; then
    echo "Por favor, insira o domínio que deseja usar (exemplo: seu-dominio.com):"
    read dominio

    # Configuração de domínio no servidor
    echo "Configurando o domínio $dominio..."

    # Atualiza o arquivo hosts
    echo "127.0.0.1 $dominio" | sudo tee -a /etc/hosts

    # Configura NGINX para o domínio
    sudo apt install -y nginx
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

    # Habilita a configuração no NGINX
    sudo ln -s /etc/nginx/sites-available/antmedia /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx

    echo "Domínio configurado com sucesso: http://$dominio"
  else
    echo "O domínio não será configurado. Você poderá acessar o Ant Media Server diretamente pelo IP do servidor."
  fi
}

# Atualiza o sistema
sudo apt update && sudo apt upgrade -y

# Instala dependências necessárias
sudo apt install -y openjdk-11-jdk wget unzip

# Define a versão do Ant Media Server
AMS_VERSION="ams-v2.12.0"

# Baixa o Ant Media Server
wget https://github.com/ant-media/Ant-Media-Server/releases/download/$AMS_VERSION/ant-media-server-$AMS_VERSION.zip

# Descompacta o arquivo baixado
unzip ant-media-server-$AMS_VERSION.zip

# Navega até o diretório descompactado
cd ant-media-server

# Executa o script de instalação
sudo ./install_ant-media-server.sh

# Configura o domínio (se solicitado)
configurar_dominio

# Inicia o serviço do Ant Media Server
sudo service antmedia start

# Exibe o status do serviço para confirmar que está em execução
sudo service antmedia status
