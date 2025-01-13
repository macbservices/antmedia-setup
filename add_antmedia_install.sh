#!/bin/bash

# Função para verificar se o usuário tem permissões de root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Este script deve ser executado como root. Tente novamente com 'sudo'."
    exit 1
  fi
}

# Função para baixar o script de instalação do Ant Media Server
fetch_install_script() {
  echo "Baixando o script de instalação do Ant Media Server..."
  wget https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh -O install_ant-media-server.sh
  if [[ $? -ne 0 ]]; then
    echo "Erro ao baixar o script de instalação. Verifique sua conexão com a internet."
    exit 1
  fi
  chmod 755 install_ant-media-server.sh
  echo "Script de instalação baixado com sucesso."
}

# Função para perguntar se deseja usar um domínio
ask_domain() {
  echo "Deseja usar um domínio personalizado para o Ant Media Server? (s/n)"
  read -r use_domain

  if [[ "$use_domain" =~ ^[Ss]$ ]]; then
    echo "Digite o domínio que deseja usar (exemplo: exemplo.com):"
    read -r domain

    # Validar domínio
    if [[ -z "$domain" || ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
      echo "Domínio inválido. Por favor, execute o script novamente e insira um domínio válido."
      exit 1
    fi

    echo "Domínio selecionado: $domain"
    DOMAIN_FLAG="--domain $domain"
  else
    echo "Nenhum domínio será usado."
    DOMAIN_FLAG=""
  fi
}

# Função para executar o script de instalação
run_install_script() {
  echo "Iniciando a instalação do Ant Media Server..."
  ./install_ant-media-server.sh $DOMAIN_FLAG
  if [[ $? -eq 0 ]]; then
    echo "Instalação concluída com sucesso!"
  else
    echo "Ocorreu um erro durante a instalação. Consulte os logs acima para mais detalhes."
  fi
}

# Execução principal do script
main() {
  check_root
  fetch_install_script
  ask_domain
  run_install_script
}

main
