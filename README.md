# Script-Win-MAJ

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell 5.1+" />
  <img src="https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white" alt="Windows 10/11" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License" />
</p>

Script de maintenance Windows conçu pour automatiser les tâches de mise à jour et d’entretien système de manière simple, propre et reproductible.

## Vue d’ensemble

Script-Win-MAJ est un projet PowerShell destiné à simplifier les opérations de maintenance courantes sur les machines Windows. Il permet d’automatiser certaines vérifications, d’appliquer les mises à jour et de centraliser l’exécution dans un flux plus fiable et documenté.

## Objectif

Le projet vise à réduire les interventions manuelles répétitives, améliorer la traçabilité des actions et faciliter la planification de maintenance sur des postes ou serveurs Windows.

## Fonctionnalités

- Compatibilité avec Windows 10 et 11
- Script PowerShell simple à exécuter
- Maintenance automatisée des composants système
- Journalisation des actions pour suivi et dépannage
- Prêt pour une exécution planifiée via le Planificateur de tâches
- Facile à personnaliser selon les besoins du poste ou du réseau

## Prérequis

Avant d’exécuter le script, vérifiez que :

- Windows 10 ou Windows 11 est installé
- PowerShell 5.1 ou version ultérieure est disponible
- Vous avez les droits administrateur si nécessaire pour la mise à jour
- Le poste peut accéder aux services de mise à jour Windows

## Installation

1. Clonez le dépôt :

```bash
git clone https://github.com/Nelson2410/Script-Win-MAJ.git
```

## Utilisation

1. Ouvrez PowerShell en mode administrateur dans le dossier du projet.

2. Exécutez le script :

```powershell
.\maj_script.ps1
```

>[!Note] 
>En cas de blocage d'exécution, tapez la commande ci-après pour léver le verrou      
```powershell
powershell -ExecutionPolicy Bypass -File .\maj_script.ps1
```

### Exécution planifiée

Le script peut être lancé automatiquement via le Planificateur de tâches Windows selon les besoins :
- au démarrage,
- chaque jour,
- chaque semaine,
- ou selon un rythme spécifique.

## Structure du projet

```text
Script_MAJ/
├── README.md
├── LICENSE
├── .gitignore
├── maj_script.ps1
├── logs/
└── docs/
```

## Dépannage

Si le script ne s’exécute pas :
- vérifiez la politique d’exécution PowerShell,
- confirmez que vous êtes administrateur,
- consultez les journaux d’exécution,
- vérifiez l’accès aux services de mise à jour système.

## Licence

Ce projet est distribué sous la licence MIT. Consultez le fichier LICENSE pour plus d’informations.

## Auteur

Nelson Bandos | Réseaux & Sécurité
- [LinkedIn](https://www.linkedin.com/in/nelson-bandos)
- [Portfolio](https://nelson-bandos.vercel.app)