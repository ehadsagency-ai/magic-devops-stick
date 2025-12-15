#!/bin/bash

################################################################################
# Magic DevOps Stick - Cleanup Script
# 
# Description: Script de nettoyage de l'environnement DevOps
# Usage: ./cleanup.sh [--full] [--help]
# Author: Magic DevOps Team
# Version: 1.0.0
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FULL_CLEANUP="${1:-0}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Fonctions Utilitaires
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $@"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $@"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $@"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@"
}

confirm() {
    local prompt="$1"
    local response
    
    read -p "$(echo -e ${YELLOW}$prompt${NC}) (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

################################################################################
# Nettoyage
################################################################################

cleanup_docker() {
    log_info "Nettoyage de Docker..."
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker non installé, skip"
        return 0
    fi
    
    # Arrêter les conteneurs
    log_info "Arrêt des conteneurs en cours..."
    docker stop $(docker ps -q) 2>/dev/null || true
    
    # Supprimer les conteneurs arrêtés
    log_info "Suppression des conteneurs arrêtés..."
    docker rm $(docker ps -a -q) 2>/dev/null || true
    
    # Nettoyer les images non utilisées
    if [ "$FULL_CLEANUP" = "--full" ]; then
        log_info "Suppression des images non utilisées..."
        docker rmi $(docker images -q) 2>/dev/null || true
    fi
    
    # Nettoyer les volumes
    log_info "Suppression des volumes non utilisés..."
    docker volume prune -f 2>/dev/null || true
    
    # Nettoyer les réseaux
    log_info "Suppression des réseaux non utilisés..."
    docker network prune -f 2>/dev/null || true
    
    log_success "Docker nettoyé"
}

cleanup_kubernetes() {
    log_info "Nettoyage de Kubernetes..."
    
    if ! command -v kubectl &> /dev/null; then
        log_warning "kubectl non installé, skip"
        return 0
    fi
    
    # Vérifier la connexion au cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_warning "Pas de cluster Kubernetes connecté, skip"
        return 0
    fi
    
    # Supprimer les déploiements
    log_info "Suppression des déploiements..."
    kubectl delete deployments --all --all-namespaces 2>/dev/null || true
    
    # Supprimer les services
    log_info "Suppression des services..."
    kubectl delete services --all --all-namespaces 2>/dev/null || true
    
    # Supprimer les pods
    log_info "Suppression des pods..."
    kubectl delete pods --all --all-namespaces 2>/dev/null || true
    
    # Supprimer les namespaces personnalisés
    log_info "Suppression des namespaces personnalisés..."
    kubectl delete namespace $(kubectl get namespace -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -v 'default\|kube-system\|kube-public\|kube-node-lease') 2>/dev/null || true
    
    log_success "Kubernetes nettoyé"
}

cleanup_terraform() {
    log_info "Nettoyage de Terraform..."
    
    if [ ! -d "$PROJECT_ROOT/configs/terraform" ]; then
        log_warning "Aucune configuration Terraform trouvée, skip"
        return 0
    fi
    
    cd "$PROJECT_ROOT/configs/terraform"
    
    # Détruire l'infrastructure
    if [ -f "terraform.tfstate" ]; then
        if confirm "Détruire l'infrastructure Terraform ?"; then
            terraform destroy -auto-approve 2>/dev/null || true
        fi
    fi
    
    # Nettoyer les fichiers temporaires
    rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
    
    log_success "Terraform nettoyé"
}

cleanup_logs() {
    log_info "Nettoyage des logs..."
    
    # Nettoyer les logs du projet
    find "$PROJECT_ROOT" -name "*.log" -type f -delete
    
    # Nettoyer les logs système
    if [ "$FULL_CLEANUP" = "--full" ]; then
        sudo journalctl --vacuum=1d 2>/dev/null || true
    fi
    
    log_success "Logs nettoyés"
}

cleanup_cache() {
    log_info "Nettoyage du cache..."
    
    # Nettoyer le cache Docker
    if command -v docker &> /dev/null; then
        docker system prune -f 2>/dev/null || true
    fi
    
    # Nettoyer le cache npm
    if command -v npm &> /dev/null; then
        npm cache clean --force 2>/dev/null || true
    fi
    
    # Nettoyer le cache pip
    if command -v pip3 &> /dev/null; then
        pip3 cache purge 2>/dev/null || true
    fi
    
    log_success "Cache nettoyé"
}

cleanup_temporary_files() {
    log_info "Suppression des fichiers temporaires..."
    
    # Nettoyer les répertoires temporaires du projet
    rm -rf "$PROJECT_ROOT"/.tmp "$PROJECT_ROOT"/.cache
    
    # Nettoyer les fichiers temporaires
    find "$PROJECT_ROOT" -name "*~" -o -name "*.swp" -o -name "*.swo" | xargs rm -f
    
    log_success "Fichiers temporaires supprimés"
}

cleanup_full() {
    log_info "Nettoyage complet en cours..."
    
    if ! confirm "Êtes-vous sûr de vouloir effectuer un nettoyage complet ?"; then
        log_warning "Nettoyage complet annulé"
        return 1
    fi
    
    cleanup_docker
    cleanup_kubernetes
    cleanup_terraform
    cleanup_logs
    cleanup_cache
    cleanup_temporary_files
    
    log_success "Nettoyage complet terminé"
}

cleanup_light() {
    log_info "Nettoyage léger en cours..."
    
    cleanup_logs
    cleanup_cache
    cleanup_temporary_files
    
    log_success "Nettoyage léger terminé"
}

show_help() {
    cat << EOF
Usage: ./cleanup.sh [OPTIONS]

Options:
    --full              Nettoyage complet (Docker, Kubernetes, Terraform, etc.)
    --help             Afficher cette aide

Exemples:
    ./cleanup.sh              # Nettoyage léger (logs, cache, fichiers temp)
    ./cleanup.sh --full       # Nettoyage complet

EOF
}

################################################################################
# Main
################################################################################

main() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          Magic DevOps Stick - Script de Nettoyage             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Traiter les arguments
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --full)
            FULL_CLEANUP="--full"
            cleanup_full
            ;;
        *)
            cleanup_light
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✓ Nettoyage terminé${NC}"
    echo ""
}

# Exécuter main
main "$@"
