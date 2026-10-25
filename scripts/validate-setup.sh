#!/usr/bin/env bash

################################################################################
# Magic DevOps Stick - Validation Script
# 
# Description: Read-only checks for the local DevOps environment
# Usage: ./scripts/validate-setup.sh
# Author: Magic DevOps Team
# Version: 1.0.0
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
DOCKER_IMAGES_READ=0
DOCKER_REPOSITORIES=''

################################################################################
# Fonctions Utilitaires
################################################################################

check_pass() {
    echo -e "${GREEN}✓${NC} $*"
    PASSED=$((PASSED + 1))
}

check_fail() {
    echo -e "${RED}✗${NC} $*"
    FAILED=$((FAILED + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
    WARNINGS=$((WARNINGS + 1))
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}

first_semver() {
    local output
    output="$("$@" 2>&1)" || return 1
    if [[ "$output" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
    else
        return 2
    fi
}

check_version() {
    local label="$1"
    local version
    shift
    if version="$(first_semver "$@")"; then
        check_pass "$label : $version"
    else
        local status=$?
        if [ "$status" -eq 2 ]; then
            check_warn "$label : commande présente, version non reconnue"
        else
            check_fail "$label : sonde de version en échec"
        fi
    fi
}

repository_present() {
    local expected="$1"
    local repository
    while IFS= read -r repository; do
        if [ "$repository" = "$expected" ]; then
            return 0
        fi
    done <<< "$DOCKER_REPOSITORIES"
    return 1
}

docker_compose_declared() {
    local help_output
    local line
    help_output="$(docker --help 2>/dev/null)" || return 2
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]+compose\*?[[:space:]]+ ]]; then
            return 0
        fi
    done <<< "$help_output"
    return 1
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
    local available_space
    if available_space="$(df -Pk "$PROJECT_ROOT" | awk 'NR == 2 {print $4}')" \
        && [[ "$available_space" =~ ^[0-9]+$ ]]; then
        local available_gib=$((10#$available_space / 1024 / 1024))
        if [ "$available_gib" -ge 20 ]; then
            check_pass "Espace disque : ${available_gib} GiB (requis : 20 GiB)"
        else
            check_fail "Espace disque insuffisant : ${available_gib} GiB (requis : 20 GiB)"
        fi
    else
        check_warn "Espace disque : capacité non mesurable"
    fi
    
    # Vérifier la RAM
    local total_ram_mb=''
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local total_ram_bytes
        if total_ram_bytes="$(sysctl -n hw.memsize 2>/dev/null)" \
            && [[ "$total_ram_bytes" =~ ^[0-9]+$ ]]; then
            total_ram_mb=$((10#$total_ram_bytes / 1024 / 1024))
        fi
    elif check_command free; then
        local measured_ram_mb
        if measured_ram_mb="$(free -m | awk '/^Mem:/ {print $2}')" \
            && [[ "$measured_ram_mb" =~ ^[0-9]+$ ]]; then
            total_ram_mb="$measured_ram_mb"
        fi
    fi
    if [[ "$total_ram_mb" =~ ^[0-9]+$ ]] && [ "$total_ram_mb" -gt 0 ]; then
        local available_gib=$((10#$total_ram_mb / 1024))
        if [ "$available_gib" -ge 16 ]; then
            check_pass "RAM : ${available_gib} GiB (recommandé : 16 GiB)"
        elif [ "$available_gib" -ge 8 ]; then
            check_warn "RAM : ${available_gib} GiB (recommandé : 16 GiB)"
        else
            check_fail "RAM insuffisante : ${available_gib} GiB (minimum : 8 GiB)"
        fi
    else
        check_warn "RAM : capacité non mesurable"
    fi
    
    # ICMP failure does not prove that HTTPS access is unavailable.
    if ping -c 1 8.8.8.8 &> /dev/null; then
        check_pass "Test ICMP vers 8.8.8.8 : OK"
    else
        check_warn "Test ICMP vers 8.8.8.8 échoué (connectivité indéterminée)"
    fi
}

validate_docker() {
    echo -e "\n${BLUE}=== Validation de Docker ===${NC}"
    
    if check_command docker; then
        check_version "Docker" docker --version
        
        # Vérifier que Docker est en cours d'exécution
        if docker ps &> /dev/null; then
            check_pass "Docker daemon : En cours d'exécution"
            if DOCKER_REPOSITORIES="$(docker image ls --format '{{.Repository}}' 2>/dev/null)"; then
                DOCKER_IMAGES_READ=1
            fi
        else
            check_fail "Docker daemon : indisponible"
        fi
        
        # Inspect the CLI command list without running the Compose plugin.
        if docker_compose_declared; then
            check_pass "Docker Compose v2 : déclaré par le CLI (fonctionnement non testé)"
        else
            local compose_probe_status=$?
            if check_command docker-compose; then
                check_pass "Docker Compose : exécutable historique présent (fonctionnement non testé)"
            elif [ "$compose_probe_status" -eq 2 ]; then
                check_warn "Docker Compose : détection du plugin v2 impossible ; exécutable historique absent"
            else
                check_warn "Docker Compose : plugin v2 non déclaré ; exécutable historique absent"
            fi
        fi
    else
        check_fail "Docker : Non installé"
    fi
}

validate_kubernetes() {
    echo -e "\n${BLUE}=== Validation de Kubernetes ===${NC}"
    
    if check_command kubectl; then
        check_version "kubectl" kubectl version --client
        
        # Cluster access may invoke an authentication plugin and change local state.
        check_warn "Cluster Kubernetes : connexion non vérifiée par ce contrôle local"
    else
        check_fail "kubectl : Non installé"
    fi
    
    if check_command kind; then
        check_version "Kind" kind --version
    else
        check_warn "Kind : Non installé"
    fi
    
    if check_command helm; then
        check_version "Helm" helm version --short
    else
        check_warn "Helm : Non installé"
    fi
}

validate_infrastructure_as_code() {
    echo -e "\n${BLUE}=== Validation de l'Infrastructure as Code ===${NC}"
    
    if check_command terraform; then
        check_pass "Terraform : commande présente, version non interrogée"
    else
        check_fail "Terraform : Non installé"
    fi
    
    if check_command ansible; then
        check_pass "Ansible : commande présente, version non interrogée"
    else
        check_fail "Ansible : Non installé"
    fi
}

validate_cicd() {
    echo -e "\n${BLUE}=== Validation de CI/CD ===${NC}"
    
    # Vérifier Git
    if check_command git; then
        check_version "Git" git --version
    else
        check_fail "Git : Non installé"
    fi
    
    # Vérifier Jenkins (via Docker)
    if [ "$DOCKER_IMAGES_READ" -eq 1 ]; then
        if repository_present 'jenkins/jenkins'; then
            check_pass "Jenkins image : Disponible"
        else
            check_warn "Jenkins image : jenkins/jenkins absent"
        fi
    elif check_command docker; then
        check_warn "Jenkins image : non vérifiée (lecture Docker indisponible)"
    fi
}

validate_monitoring() {
    echo -e "\n${BLUE}=== Validation du Monitoring ===${NC}"
    
    if check_command prometheus; then
        check_version "Prometheus" prometheus --version
    else
        check_warn "Prometheus : Non installé"
    fi
    
    if [ "$DOCKER_IMAGES_READ" -eq 1 ]; then
        if repository_present 'grafana/grafana'; then
            check_pass "Grafana image : Disponible"
        else
            check_warn "Grafana image : grafana/grafana absent"
        fi
    elif check_command docker; then
        check_warn "Grafana image : non vérifiée (lecture Docker indisponible)"
    fi
}

validate_security() {
    echo -e "\n${BLUE}=== Validation de la Sécurité ===${NC}"
    
    if check_command vault; then
        check_version "Vault" vault version
    else
        check_warn "Vault : Non installé"
    fi
    
    # Sudo may log an authentication attempt even with -n; keep this probe local.
    check_warn "Permissions sudo : non vérifiées par ce contrôle local"
}

validate_cloud_cli() {
    echo -e "\n${BLUE}=== Validation des Cloud CLI ===${NC}"
    
    if check_command aws; then
        check_pass "AWS CLI : installé (version non interrogée)"
    else
        check_warn "AWS CLI : Non installé"
    fi
    
    if check_command az; then
        check_pass "Azure CLI : installé (version non interrogée)"
    else
        check_warn "Azure CLI : Non installé"
    fi
    
    if check_command gcloud; then
        check_pass "Google Cloud SDK : installé (version non interrogée)"
    else
        check_warn "Google Cloud SDK : Non installé"
    fi
}

validate_programming_languages() {
    echo -e "\n${BLUE}=== Validation des Langages de Programmation ===${NC}"
    
    if check_command python3; then
        check_version "Python 3" python3 --version
    else
        check_warn "Python 3 : Non installé"
    fi
    
    if check_command node; then
        check_version "Node.js" node --version
    else
        check_warn "Node.js : Non installé"
    fi
    
    if check_command go; then
        check_version "Go" go version
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
    # Preserve captured output and run without TERM in non-interactive shells.
    if [[ -t 1 && -n "${TERM:-}" && "$TERM" != dumb ]]; then
        clear || :
    fi
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
