# Tableau de bord Termux — JEPH ODG

Un tableau de bord en couleurs pour ton téléphone, directement dans Termux :
batterie, température, stockage, RAM, réseau et durée d'activité, avec mise à jour automatique.

## Installation (une seule commande)

```bash
curl -fsSL https://raw.githubusercontent.com/jephteouedraogo314-star/termux-dashboard/main/install.sh | bash
```

Puis lance-le avec :

```bash
dash
```

> Pour afficher la batterie et le réseau, installe aussi l'appli **Termux:API** (disponible sur F-Droid, comme Termux).

## Menu

| Touche | Action |
|--------|--------|
| 1 | Rafraîchir |
| 2 | Nettoyer le cache |
| 3 | Sauvegarde GitHub (dossier `~/backup`) |
| 4 | Mise à jour du tableau de bord |
| 0 | Quitter |

## Sauvegarde GitHub (option 3)

```bash
git clone https://github.com/jephteouedraogo314-star/TON_DEPOT_PRIVE.git ~/backup
```

Tout ce qui est dans `~/backup` sera envoyé. Garde ce dépôt **privé**.

## Désinstallation

```bash
rm -rf ~/.jeph $PREFIX/bin/dash
```

## Licence

MIT
