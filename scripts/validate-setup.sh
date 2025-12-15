#!/bin/bash

################################################################################
# Magic DevOps Stick - Validation Script
# 
# Description: Script de validation complète de l'environnement DevOps
# Usage: ./validate-setup.sh [--verbose]
# Author: Magic DevOps Team
# Version: 1.0.0
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERBOSE="${1:-0}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Compteurs
PASSED=0
FAILED=0
WARNINGS=0

################################################################################
# Fonctions Utilitaires
################################################################################

check_pass() {
    echo -e "${GREEN}✓${NC} $@"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $@"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $@"
    ((WARNINGS++))
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}

get_version() {
    local cmd="$1"
    local flag="${2:---version}"
    
    if check_command "$cmd"; then
        "$cmd" $flag 2>&1 | head -1
    else
        echo "Not installed"
    fi
}

################################################################################
# Validations
################################################################################

validate_system() {
    echo -e "\n${BLUE}=== Validation du Système ===${NC}"
    
    # Vérifier l'OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        check_pass "OS : Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        check_pass "OS : macOS"
    else
        check_fail "OS non supporté : $OSTYPE"
    fi
    
    # Vérifier l'espace disque
    local available_space=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $4}')
    local available_gb=$((available_space / 1024 / 1024))
    
    if [ "$available_gb" -ge 20 ]; then
        check_pass "Espace disque : ${available_gb} GB (requis : 20 GB)"
    else
        check_fail "Espace disque insuffisant : ${available_gb} GB (requis : 20 GB)"
    fi
    
    # Vérifier la RAM
    local available_ram=$(free -m 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "0")
    if [ "$available_ram" -gt 0 ]; then
        local available_gb=$((available_ram / 1024))
        if [ "$available_gb" -ge 16 ]; then
            check_pass "RAM : ${available_gb} GB (recommandé : 16 GB)"
        elif [ "$available_gb" -ge 8 ]; then
            check_warn "RAM : ${available_gb} GB (recommandé : 16 GB)"
        else
            check_fail "RAM insuffisante : ${available_gb} GB (minimum : 8 GB)"
        fi
    fi
    
    # Vérifier la connexion Internet
    if ping -c 1 8.8.8.8 &> /dev/null; then
        check_pass "Connexion Internet : OK"
    else
        check_warn "Connexion Internet : Non disponible"
    fi
}

validate_docker() {
    echo -e "\n${BLUE}=== Validation de Docker ===${NC}"
    
    if check_command docker; then
        check_pass "Docker installé : $(docker --version | cut -d' ' -f3)"
        
        # Vérifier que Docker est en cours d'exécution
        if docker ps &> /dev/null; then
            check_pass "Docker daemon : En cours d'exécution"
        else
            check_fail "Docker daemon : Non en cours d'exécution"
        fi
        
        # Vérifier Docker Compose
        if check_command docker-compose; then
            check_pass "Docker Compose : $(docker-compose --version | cut -d' ' -f3)"
        else
            check_warn "Docker Compose : Non installé"
        fi
    else
        check_fail "Docker : Non installé"
    fi
}

validate_kubernetes() {
    echo -e "\n${BLUE}=== Validation de Kubernetes ===${NC}"
    
    if check_command kubectl; then
        local k8s_version=$(kubectl version --client --short 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
        check_pass "kubectl : $k8s_version"
        
        # Vérifier la connexion au cluster
        if kubectl cluster-info &> /dev/null; then
            check_pass "Cluster Kubernetes : Connecté"
        else
            check_warn "Cluster Kubernetes : Non connecté"
        fi
    else
        check_fail "kubectl : Non installé"
    fi
    
    if check_command kind; then
        check_pass "Kind : $(kind --version | cut -d' ' -f3)"
    else
        check_warn "Kind : Non installé"
    fi
    
    if check_command helm; then
        local helm_version=$(helm version --short 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
        check_pass "Helm : $helm_version"
    else
        check_warn "Helm : Non installé"
    fi
}

validate_infrastructure_as_code() {
    echo -e "\n${BLUE}=== Validation de l'Infrastructure as Code ===${NC}"
    
    if check_command terraform; then
        local tf_version=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
        check_pass "Terraform : $tf_version"
    else
        check_fail "Terraform : Non installé"
    fi
    
    if check_command ansible; then
        local ansible_version=$(ansible --version | head -1 | grep -oP '\d+\.\d+\.\d+')
        check_pass "Ansible : $ansible_version"
    else
        check_fail "Ansible : Non installé"
    fi
}

validate_cicd() {
    echo -e "\n${BLUE}=== Validation de CI/CD ===${NC}"
    
    # Vérifier Git
    if check_command git; then
        check_pass "Git : $(git --version | cut -d' ' -f3)"
    else
        check_fail "Git : Non installé"
    fi
    
    # Vérifier Jenkins (via Docker)
    if check_command docker; then
        if docker images | grep -q jenkins; then
            check_pass "Jenkins image : Disponible"
        else
            check_warn "Jenkins image : Non téléchargée"
        fi
    fi
}

validate_monitoring() {
    echo -e "\n${BLUE}=== Validation du Monitoring ===${NC}"
    
    if check_command prometheus; then
        local prom_version=$(prometheus --version 2>&1 | head -1 | grep -oP '\d+\.\d+\.\d+')
        check_pass "Prometheus : $prom_version"
    else
        check_warn "Prometheus : Non installé"
    fi
    
    if check_command docker; then
        if docker images | grep -q grafana; then
            check_pass "Grafana image : Disponible"
        else
            check_warn "Grafana image : Non téléchargée"
        fi
    fi
}

validate_security() {
    echo -e "\n${BLUE}=== Validation de la Sécurité ===${NC}"
    
    if check_command vault; then
        local vault_version=$(vault version 2>&1 | grep -oP 'Vault v\d+\.\d+\.\d+' | cut -d' ' -f2)
        check_pass "Vault : $vault_version"
    else
        check_warn "Vault : Non installé"
    fi
    
    # Vérifier les permissions sudo
    if sudo -n true 2>/dev/null; then
        check_pass "Permissions sudo : OK (sans mot de passe)"
    else
        check_warn "Permissions sudo : Mot de passe requis"
    fi
}

validate_cloud_cli() {
    echo -e "\n${BLUE}=== Validation des Cloud CLI ===${NC}"
    
    if check_command aws; then
        local aws_version=$(aws --version 2>&1 | cut -d' ' -f1)
        check_pass "AWS CLI : $aws_version"
    else
        check_warn "AWS CLI : Non installé"
    fi
    
    if check_command az; then
        local az_version=$(az version --output json 2>/dev/null | grep -o '"azure-cli": "[^"]*"' | cut -d'"' -f4)
        check_pass "Azure CLI : $az_version"
    else
        check_warn "Azure CLI : Non installé"
    fi
    
    if check_command gcloud; then
        local gcloud_version=$(gcloud --version 2>&1 | head -1 | grep -oP '\d+\.\d+\.\d+')
        check_pass "Google Cloud SDK : $gcloud_version"
    else
        check_warn "Google Cloud SDK : Non installé"
    fi
}

validate_programming_languages() {
    echo -e "\n${BLUE}=== Validation des Langages de Programmation ===${NC}"
    
    if check_command python3; then
        local py_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        check_pass "Python 3 : $py_version"
    else
        check_warn "Python 3 : Non installé"
    fi
    
    if check_command node; then
        local node_version=$(node --version)
        check_pass "Node.js : $node_version"
    else
        check_warn "Node.js : Non installé"
    fi
    
    if check_command go; then
        local go_version=$(go version 2>&1 | grep -oP 'go\d+\.\d+\.\d+')
        check_pass "Go : $go_version"
    else
        check_warn "Go : Non installé"
    fi
}

validate_project_structure() {
    echo -e "\n${BLUE}=== Validation de la Structure du Projet ===${NC}"
    
    local dirs=("docs" "scripts" "configs" "examples" "exercises" "tools")
    
    for dir in "${dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            check_pass "Répertoire $dir : Existe"
        else
            check_fail "Répertoire $dir : Manquant"
        fi
    done
    
    # Vérifier les fichiers de documentation
    local docs=("README.md" "GETTING_STARTED.md" "INSTALLATION.md")
    for doc in "${docs[@]}"; do
        if [ -f "$PROJECT_ROOT/docs/$doc" ]; then
            check_pass "Documentation $doc : Existe"
        else
            check_warn "Documentation $doc : Manquante"
        fi
    done
}

################################################################################
# Rapport Final
################################################################################

generate_report() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                    RAPPORT DE VALIDATION${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
    
    echo "Résultats :"
    echo -e "  ${GREEN}✓ Réussis${NC}     : $PASSED"
    echo -e "  ${RED}✗ Échoués${NC}     : $FAILED"
    echo -e "  ${YELLOW}⚠ Avertissements${NC} : $WARNINGS"
    echo ""
    
    local total=$((PASSED + FAILED + WARNINGS))
    local success_rate=$((PASSED * 100 / total))
    
    echo "Taux de réussite : $success_rate%"
    echo ""
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ Validation réussie ! Votre environnement est prêt.${NC}"
        return 0
    else
        echo -e "${RED}✗ Validation échouée. Veuillez corriger les erreurs ci-dessus.${NC}"
        return 1
    fi
}

################################################################################
# Main
################################################################################

main() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║      Magic DevOps Stick - Validation de l'Installation        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Exécuter les validations
    validate_system
    validate_docker
    validate_kubernetes
    validate_infrastructure_as_code
    validate_cicd
    validate_monitoring
    validate_security
    validate_cloud_cli
    validate_programming_languages
    validate_project_structure
    
    # Générer le rapport
    generate_report
}

# Exécuter main
main "$@"
