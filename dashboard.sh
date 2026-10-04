#!/data/data/com.termux/files/usr/bin/bash
# JEPH ODG - Tableau de bord Termux
# Prérequis : pkg install termux-api git  +  appli Termux:API installée

R=$'\e[1;31m'; G=$'\e[1;32m'; Y=$'\e[1;33m'; C=$'\e[1;36m'; M=$'\e[1;35m'; N=$'\e[0m'
BACKUP_DIR="${JEPH_BACKUP_DIR:-$HOME/backup}"   # dossier relié à ton dépôt GitHub
REFRESH=5                                        # secondes entre deux rafraîchissements

# Barre de 10 blocs. $1 = pourcentage, $2 = 1 si "bas = mauvais" (batterie)
bar() {
    local p=$1 inv=$2 w=10 f i col s=""
    (( p < 0 )) && p=0
    (( p > 100 )) && p=100
    f=$(( p * w / 100 ))
    if [ "$inv" = 1 ]; then
        if (( p <= 20 )); then col=$R; elif (( p <= 50 )); then col=$Y; else col=$G; fi
    else
        if (( p >= 90 )); then col=$R; elif (( p >= 70 )); then col=$Y; else col=$G; fi
    fi
    for (( i = 0; i < w; i++ )); do
        (( i < f )) && s+="█" || s+="░"
    done
    printf '%s%s%s' "$col" "$s" "$N"
}

# Lit une valeur dans un JSON simple : jget cle "$json"
jget() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"\?[^,}\"]*" <<<"$2" | head -n1 | sed 's/.*:[[:space:]]*"\?//'; }

kb_go() { awk -v k="$1" 'BEGIN { printf "%.1f", k / 1048576 }'; }

banner() {
    echo "${C}  ███ █████ ████  █   █    ███  ████   ████"
    echo "    █ █     █   █ █   █   █   █ █   █ █    "
    echo "    █ ████  ████  █████   █   █ █   █ █  ██"
    echo "█   █ █     █     █   █   █   █ █   █ █   █"
    echo " ███  █████ █     █   █    ███  ████   ████${N}"
    echo "${M}══════════════════════════════════════════${N}"
}

render() {
    banner

    # Batterie
    local bat pct st temp
    bat=$(timeout 5 termux-battery-status 2>/dev/null)
    if [ -n "$bat" ]; then
        pct=$(jget percentage "$bat"); pct=${pct:-0}
        st=$(jget status "$bat")
        temp=$(jget temperature "$bat"); temp=${temp:-0}
        case "$st" in
            CHARGING) st="charge" ;; FULL) st="pleine" ;; *) st="décharge" ;;
        esac
        printf ' 🔋 Batterie : %3s%% %s  (%s)\n' "$pct" "$(bar "$pct" 1)" "$st"
        printf ' 🌡  Temp.    : %.0f°C\n' "$temp"
    else
        echo " 🔋 Batterie : indisponible (installe Termux:API)"
    fi

    # Stockage
    local su st_ sp
    read -r su st_ < <(df -k "$HOME" | awk 'NR==2 { print $3, $2 }')
    if [ -n "$st_" ] && (( st_ > 0 )); then
        sp=$(( su * 100 / st_ ))
        printf ' 💾 Stockage : %s / %s Go  %s\n' "$(kb_go "$su")" "$(kb_go "$st_")" "$(bar "$sp" 0)"
    fi

    # RAM
    local mt ma mu mp
    mt=$(awk '/MemTotal/ { print $2 }' /proc/meminfo 2>/dev/null)
    ma=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo 2>/dev/null)
    if [ -n "$mt" ] && [ -n "$ma" ]; then
        mu=$(( mt - ma )); mp=$(( mu * 100 / mt ))
        printf ' 🧠 RAM      : %s / %s Go  %s\n' "$(kb_go "$mu")" "$(kb_go "$mt")" "$(bar "$mp" 0)"
    fi

    # Réseau
    local wifi ip
    wifi=$(timeout 5 termux-wifi-connectioninfo 2>/dev/null)
    ip=$(jget ip "$wifi")
    if [ -n "$ip" ] && [ "$ip" != "0.0.0.0" ]; then
        echo " 📶 Réseau   : Wi-Fi · $ip"
    else
        echo " 📶 Réseau   : Données mobiles"
    fi

    # Durée d'activité
    local up
    up=$(awk '{ print int($1) }' /proc/uptime 2>/dev/null)
    if [ -n "$up" ]; then
        printf ' ⏱  Actif    : %d j %d h %d min\n' $(( up / 86400 )) $(( up % 86400 / 3600 )) $(( up % 3600 / 60 ))
    fi

    echo "${M}══════════════════════════════════════════${N}"
    echo " ${Y}[1]${N} Rafraîchir        ${Y}[2]${N} Nettoyer le cache"
    echo " ${Y}[3]${N} Sauvegarde GitHub ${Y}[4]${N} Mise à jour"
    echo " ${Y}[0]${N} Quitter"
}

attendre() { read -rsn1 -p "Appuie sur une touche..."; }

nettoyer() {
    tput cnorm; echo
    local avant apres
    avant=$(df -k "$HOME" | awk 'NR==2 { print $3 }')
    pkg clean -y &>/dev/null || apt-get clean &>/dev/null
    rm -rf "$HOME/.cache"/* 2>/dev/null
    apres=$(df -k "$HOME" | awk 'NR==2 { print $3 }')
    echo "Cache nettoyé : $(( (avant - apres) / 1024 )) Mo libérés."
    attendre; tput civis
}

sauvegarder() {
    tput cnorm; echo
    if [ ! -d "$BACKUP_DIR/.git" ]; then
        echo "Dépôt introuvable dans $BACKUP_DIR."
        echo "Clone d'abord ton dépôt GitHub : git clone <url> $BACKUP_DIR"
    else
        cd "$BACKUP_DIR" || return
        git add -A
        git commit -m "Sauvegarde $(date '+%Y-%m-%d %H:%M')" 2>&1 | tail -n 2
        git push 2>&1 | tail -n 3
    fi
    attendre; tput civis
}

mettre_a_jour() {
    tput cnorm; echo
    local raw
    raw=$(cat "$HOME/.jeph/raw_url" 2>/dev/null)
    if [ -z "$raw" ]; then
        echo "Source inconnue : réinstalle avec la commande du README."
    elif curl -fsSL "$raw/dashboard.sh" -o "$HOME/.jeph/dashboard.sh.new"; then
        mv "$HOME/.jeph/dashboard.sh.new" "$HOME/.jeph/dashboard.sh"
        chmod +x "$HOME/.jeph/dashboard.sh"
        echo "Mise à jour effectuée. Relance avec : dash"
    else
        echo "Échec du téléchargement (vérifie ta connexion)."
    fi
    attendre; tput civis
}

# Mode test : un seul affichage puis sortie
[ "$1" = "--once" ] && { render; exit 0; }

trap 'tput cnorm; clear; exit 0' INT TERM
tput civis
while true; do
    out=$(render)
    printf '\e[H\e[J%s\n' "$out"
    read -rsn1 -t "$REFRESH" k || continue
    case "$k" in
        2) nettoyer ;;
        3) sauvegarder ;;
        4) mettre_a_jour ;;
        0) tput cnorm; clear; exit 0 ;;
    esac
done
