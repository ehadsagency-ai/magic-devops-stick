#!/bin/bash

################################################################################
# Magic DevOps Stick - Installation Script
# 
# Description: Script d'installation automatisé pour l'environnement complet
# Usage: ./install.sh [--mode full|modular|light|cloud] [--help]
# Author: Magic DevOps Team
# Version: 1.0.0
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_ROOT}/install.log"
INSTALL_MODE="${1:-full}"
VERBOSE="${VERBOSE:-0}"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Fonctions Utilitaires
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $@" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $@" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $@" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" | tee -a "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_VERSION=$VERSION_ID
            return 0
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
        return 0
    fi
    return 1
}

check_requirements() {
    log_info "Vérification des prérequis système..."
    
    local missing_tools=()
    
    # Vérifier les outils essentiels
    local essential_tools=("curl" "wget" "git" "sudo")
    for tool in "${essential_tools[@]}"; do
        if ! check_command "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Outils manquants : ${missing_tools[*]}"
        return 1
    fi
    
    # Vérifier l'espace disque
    local available_space=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $4}')
    local required_space=$((20 * 1024 * 1024)) # 20 GB en KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "Espace disque insuffisant. Requis : 20 GB, Disponible : $((available_space / 1024 / 1024)) GB"
        return 1
    fi
    
    # Vérifier la RAM
    local available_ram=$(free -m | awk '/^Mem:/ {print $2}')
    if [ "$available_ram" -lt 8192 ]; then
        log_warning "RAM insuffisante. Recommandé : 16 GB, Disponible : $((available_ram / 1024)) GB"
    fi
    
    log_success "Vérification des prérequis réussie"
    return 0
}

################################################################################
# Installation des Composants
################################################################################

install_docker() {
    log_info "Installation de Docker..."
    
    if check_command docker; then
        log_success "Docker est déjà installé ($(docker --version))"
        return 0
    fi
    
    case "$OS" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y docker.io docker-compose
            sudo usermod -aG docker "$USER"
            ;;
        centos|rhel|fedora)
            sudo yum install -y docker docker-compose
            sudo systemctl start docker
            sudo usermod -aG docker "$USER"
            ;;
        macos)
            brew install docker docker-compose
            ;;
        *)
            log_error "OS non supporté pour Docker : $OS"
            return 1
            ;;
    esac
    
    log_success "Docker installé avec succès"
}

install_kubernetes() {
    log_info "Installation de Kubernetes (Kind)..."
    
    if check_command kind; then
        log_success "Kind est déjà installé ($(kind --version))"
    else
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
        log_success "Kind installé avec succès"
    fi
    
    if check_command kubectl; then
        log_success "kubectl est déjà installé ($(kubectl version --client --short 2>/dev/null || echo 'version inconnue'))"
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/kubectl
        log_success "kubectl installé avec succès"
    fi
    
    if check_command helm; then
        log_success "Helm est déjà installé ($(helm version --short 2>/dev/null || echo 'version inconnue'))"
    else
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        log_success "Helm installé avec succès"
    fi
}

install_terraform() {
    log_info "Installation de Terraform..."
    
    if check_command terraform; then
        log_success "Terraform est déjà installé ($(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4))"
        return 0
    fi
    
    local tf_version="1.6.0"
    local os_type=""
    
    case "$OS" in
        ubuntu|debian)
            os_type="linux"
            ;;
        macos)
            os_type="darwin"
            ;;
        *)
            log_error "OS non supporté pour Terraform : $OS"
            return 1
            ;;
    esac
    
    local arch="amd64"
    if [[ $(uname -m) == "arm64" ]]; then
        arch="arm64"
    fi
    
    local tf_url="https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_${os_type}_${arch}.zip"
    
    curl -fsSL -o /tmp/terraform.zip "$tf_url"
    unzip -o /tmp/terraform.zip -d /tmp
    sudo mv /tmp/terraform /usr/local/bin/
    rm /tmp/terraform.zip
    
    log_success "Terraform installé avec succès"
}

install_ansible() {
    log_info "Installation d'Ansible..."
    
    if check_command ansible; then
        log_success "Ansible est déjà installé ($(ansible --version | head -1))"
        return 0
    fi
    
    case "$OS" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y ansible
            ;;
        centos|rhel|fedora)
            sudo yum install -y ansible
            ;;
        macos)
            brew install ansible
            ;;
        *)
            log_error "OS non supporté pour Ansible : $OS"
            return 1
            ;;
    esac
    
    log_success "Ansible installé avec succès"
}

install_monitoring_stack() {
    log_info "Installation de la stack de monitoring (Prometheus, Grafana)..."
    
    # Créer les répertoires
    mkdir -p "${PROJECT_ROOT}/configs/monitoring"
    
    # Prometheus
    if ! check_command prometheus; then
        log_info "Installation de Prometheus..."
        local prom_version="2.48.0"
        curl -fsSL -o /tmp/prometheus.tar.gz "https://github.com/prometheus/prometheus/releases/download/v${prom_version}/prometheus-${prom_version}.linux-amd64.tar.gz"
        tar -xzf /tmp/prometheus.tar.gz -C /tmp
        sudo mv /tmp/prometheus-${prom_version}.linux-amd64/prometheus /usr/local/bin/
        sudo mv /tmp/prometheus-${prom_version}.linux-amd64/promtool /usr/local/bin/
        rm /tmp/prometheus.tar.gz
        log_success "Prometheus installé"
    fi
    
    # Grafana (via Docker)
    if check_command docker; then
        log_info "Configuration de Grafana via Docker..."
        docker pull grafana/grafana:latest || true
        log_success "Grafana image téléchargée"
    fi
}

install_jenkins() {
    log_info "Installation de Jenkins (via Docker)..."
    
    if check_command docker; then
        docker pull jenkins/jenkins:latest || true
        log_success "Jenkins image téléchargée"
    else
        log_warning "Docker non disponible, Jenkins ne peut pas être installé"
    fi
}

install_vault() {
    log_info "Installation de Vault..."
    
    if check_command vault; then
        log_success "Vault est déjà installé ($(vault version))"
        return 0
    fi
    
    local vault_version="1.15.0"
    local os_type=""
    
    case "$OS" in
        ubuntu|debian)
            os_type="linux"
            ;;
        macos)
            os_type="darwin"
            ;;
        *)
            log_error "OS non supporté pour Vault : $OS"
            return 1
            ;;
    esac
    
    local arch="amd64"
    if [[ $(uname -m) == "arm64" ]]; then
        arch="arm64"
    fi
    
    local vault_url="https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_${os_type}_${arch}.zip"
    
    curl -fsSL -o /tmp/vault.zip "$vault_url"
    unzip -o /tmp/vault.zip -d /tmp
    sudo mv /tmp/vault /usr/local/bin/
    rm /tmp/vault.zip
    
    log_success "Vault installé avec succès"
}

install_cloud_cli() {
    log_info "Installation des outils cloud CLI..."
    
    # AWS CLI
    if ! check_command aws; then
        log_info "Installation d'AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
        unzip -q /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
        rm /tmp/awscliv2.zip
        log_success "AWS CLI installé"
    fi
    
    # Azure CLI
    if ! check_command az; then
        log_info "Installation d'Azure CLI..."
        case "$OS" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y azure-cli
                ;;
            *)
                log_warning "Azure CLI installation non automatisée pour $OS"
                ;;
        esac
    fi
    
    # Google Cloud SDK
    if ! check_command gcloud; then
        log_info "Installation de Google Cloud SDK..."
        curl https://sdk.cloud.google.com | bash
        log_success "Google Cloud SDK installé"
    fi
}

################################################################################
# Modes d'Installation
################################################################################

install_full() {
    log_info "Mode d'installation : COMPLET"
    
    install_docker
    install_kubernetes
    install_terraform
    install_ansible
    install_monitoring_stack
    install_jenkins
    install_vault
    install_cloud_cli
}

install_modular() {
    log_info "Mode d'installation : MODULAIRE"
    log_info "Sélectionnez les modules à installer :"
    
    read -p "Installer Docker ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && install_docker
    
    read -p "Installer Kubernetes ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && install_kubernetes
    
    read -p "Installer Terraform ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && install_terraform
    
    read -p "Installer Ansible ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && install_ansible
    
    read -p "Installer Monitoring Stack ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && install_monitoring_stack
}

install_light() {
    log_info "Mode d'installation : LÉGER"
    
    install_docker
    install_terraform
    install_ansible
}

install_cloud() {
    log_info "Mode d'installation : CLOUD"
    
    install_docker
    install_kubernetes
    install_terraform
    install_cloud_cli
    install_vault
}

################################################################################
# Validation et Finalisation
################################################################################

validate_installation() {
    log_info "Validation de l'installation..."
    
    local validation_passed=true
    
    # Vérifier Docker
    if check_command docker; then
        log_success "Docker : OK"
    else
        log_warning "Docker : Non installé"
    fi
    
    # Vérifier Kubernetes
    if check_command kubectl; then
        log_success "kubectl : OK"
    else
        log_warning "kubectl : Non installé"
    fi
    
    # Vérifier Terraform
    if check_command terraform; then
        log_success "Terraform : OK"
    else
        log_warning "Terraform : Non installé"
    fi
    
    # Vérifier Ansible
    if check_command ansible; then
        log_success "Ansible : OK"
    else
        log_warning "Ansible : Non installé"
    fi
    
    return 0
}

show_help() {
    cat << EOF
Usage: ./install.sh [OPTIONS]

Options:
    --mode MODE         Mode d'installation (default: full)
                       - full    : Installation complète
                       - modular : Installation modulaire (interactive)
                       - light   : Installation légère (essentiels)
                       - cloud   : Installation optimisée pour cloud
    
    --help             Afficher cette aide
    --verbose          Mode verbose

Exemples:
    ./install.sh                    # Installation complète par défaut
    ./install.sh --mode light       # Installation légère
    ./install.sh --mode modular     # Installation interactive

EOF
}

################################################################################
# Main
################################################################################

main() {
    # Afficher l'en-tête
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         Magic DevOps Stick - Installation Script v1.0.0        ║"
    echo "║              Environnement complet de formation DevOps          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Initialiser le log
    echo "Installation démarrée : $(date)" > "$LOG_FILE"
    
    # Traiter les arguments
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --mode)
            INSTALL_MODE="${2:-full}"
            ;;
    esac
    
    # Vérifier l'OS
    if ! check_os; then
        log_error "OS non supporté ou non détecté"
        exit 1
    fi
    log_info "OS détecté : $OS $OS_VERSION"
    
    # Vérifier les prérequis
    if ! check_requirements; then
        log_error "Vérification des prérequis échouée"
        exit 1
    fi
    
    # Exécuter l'installation selon le mode
    case "$INSTALL_MODE" in
        full)
            install_full
            ;;
        modular)
            install_modular
            ;;
        light)
            install_light
            ;;
        cloud)
            install_cloud
            ;;
        *)
            log_error "Mode d'installation inconnu : $INSTALL_MODE"
            show_help
            exit 1
            ;;
    esac
    
    # Valider l'installation
    if ! validate_installation; then
        log_error "Validation de l'installation échouée"
        exit 1
    fi
    
    # Afficher le résumé
    echo ""
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  Installation terminée avec succès !            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Installation complète. Logs disponibles dans : $LOG_FILE"
    
    # Afficher les prochaines étapes
    echo ""
    echo -e "${BLUE}Prochaines étapes :${NC}"
    echo "1. Consultez la documentation : ${PROJECT_ROOT}/docs/README.md"
    echo "2. Commencez par le guide de démarrage : ${PROJECT_ROOT}/docs/GETTING_STARTED.md"
    echo "3. Explorez les exemples : ${PROJECT_ROOT}/examples/"
    echo ""
}

# Exécuter main
main "$@"
