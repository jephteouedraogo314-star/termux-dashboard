#!/data/data/com.termux/files/usr/bin/bash
# Installateur du tableau de bord JEPH ODG pour Termux
# Usage : curl -fsSL https://raw.githubusercontent.com/jephteouedraogo314-star/termux-dashboard/main/install.sh | bash

GH_USER="jephteouedraogo314-star"
REPO="termux-dashboard"
RAW="https://raw.githubusercontent.com/$GH_USER/$REPO/main"

main() {
    echo "==> Installation des paquets"
    pkg update -y && pkg install -y termux-api git curl || { echo "Échec de l'installation des paquets."; exit 1; }

    echo "==> Téléchargement du tableau de bord"
    mkdir -p "$HOME/.jeph"
    curl -fsSL "$RAW/dashboard.sh" -o "$HOME/.jeph/dashboard.sh" || { echo "Téléchargement impossible : vérifie le dépôt (public ?)."; exit 1; }
    chmod +x "$HOME/.jeph/dashboard.sh"
    echo "$RAW" > "$HOME/.jeph/raw_url"

    echo "==> Création du raccourci « dash »"
    ln -sf "$HOME/.jeph/dashboard.sh" "$PREFIX/bin/dash"

    echo
    echo "Installation terminée !"
    echo "Lance le tableau de bord avec :  dash"
    echo "Pour la batterie et le réseau, installe aussi l'appli Termux:API (F-Droid)."
}

main "$@" </dev/null
