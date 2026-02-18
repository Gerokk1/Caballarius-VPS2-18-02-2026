# Bugs Rencontres — VPS2

## BUG-001 : Clone accidentel du repo VPS1
- Date : 2026-02-18
- Symptome : Le repo VPS1 (Caballarius-2-15-02-2026) a ete clone dans le dossier VPS2
- Cause : Brief initial incorrect — le VPS2 etait decrit comme copie du VPS1
- Correction : Dossier clone supprime, brief corrige
- Statut : RESOLU

## BUG-002 : Bash ne fonctionne pas en local
- Date : 2026-02-18
- Symptome : Toutes les commandes bash retournent exit code 1 sans output
- Cause : Probleme de configuration shell dans l'environnement Claude Code sur ce projet Windows
- Correction : Utilisation de PowerShell a la place
- Statut : CONTOURNE (pas de fix, PowerShell utilise comme alternative)

## BUG-003 : Ports 80/443 bloques par le provider
- Date : 2026-02-18
- Symptome : Let's Encrypt timeout en se connectant a cblrs.net:80 depuis l'exterieur. Curl local OK (200) mais curl externe timeout.
- Cause : Le provider (hebergeur) a un firewall reseau qui bloque les ports 80 et 443 entrants. UFW et iptables du serveur sont corrects.
- Correction necessaire : Ouvrir les ports 80 et 443 dans le panneau d'administration de l'hebergeur
- Impact : SSL impossible tant que les ports ne sont pas ouverts
- Statut : EN ATTENTE (action utilisateur requise)

## BUG-004 : www.cblrs.net pointe vers VPS1
- Date : 2026-02-18
- Symptome : dig www.cblrs.net retourne 83.228.216.95 (IP du VPS1) au lieu de 83.228.211.132 (VPS2)
- Cause : Enregistrement DNS www mal configure
- Correction : Mettre a jour l'enregistrement DNS www.cblrs.net pour pointer vers 83.228.211.132
- Statut : EN ATTENTE (action utilisateur requise)
