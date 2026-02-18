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

## BUG-003 : Ports 80/443 bloques par le Security Group Infomaniak
- Date : 2026-02-18
- Symptome : Let's Encrypt timeout. Curl local OK (200) mais curl externe timeout. TCP connect OK mais HTTP response timeout.
- Diagnostic : canyouseeme.org confirme port 80 ferme. ifconfig.co confirme reachable=false. Le serveur sort en IPv6 (2001:1600:18:200::40).
- Cause : Security Group Infomaniak (firewall reseau) n'autorise que SSH (port 22). Les ports 80/443 ne sont pas ouverts dans le Security Group.
- Correction : Ouvrir ports 80 et 443 TCP inbound dans le Security Group du VPS via manager.infomaniak.com (VPS ov-2e0428)
- Impact : SSL impossible, sites inaccessibles depuis l'exterieur
- Statut : RESOLU — Ports ouverts dans Security Group Infomaniak, SSL obtenu pour cblrs.net

## BUG-004 : www.cblrs.net pointe vers VPS1
- Date : 2026-02-18
- Symptome : dig www.cblrs.net retourne 83.228.216.95 (IP du VPS1) au lieu de 83.228.211.132 (VPS2)
- Cause : Enregistrement DNS *.cblrs.net pointait vers VPS1
- Correction : Utilisateur a mis a jour le DNS wildcard *.cblrs.net -> 83.228.211.132
- Statut : RESOLU

## BUG-005 : OpenClaw config JSON corrompue par heredoc SSH
- Date : 2026-02-18
- Symptome : Container openclaw-bunker crash en boucle "JSON5 parse failed"
- Cause : Le passage PowerShell → SSH → heredoc supprime tous les guillemets doubles du JSON
- Correction : Encodage base64 dans PowerShell, transfert en base64, decodage sur le serveur
- Statut : RESOLU

## BUG-006 : OpenClaw config avec cles non reconnues
- Date : 2026-02-18
- Symptome : "Config invalid" + "Unknown config keys" au demarrage
- Cause : Le config contenait des cles que OpenClaw ne reconnait pas
- Cles invalides retirees : security (racine), skills.allowedSources/blockedSources/autoInstall, agents.defaults.model.secondary, models.providers.google.api="google-genai"
- Correction : Config reecrit avec uniquement les cles valides
- Statut : RESOLU

## BUG-007 : OpenClaw gateway ecoute sur loopback dans le container
- Date : 2026-02-18
- Symptome : curl http://127.0.0.1:18789/ retourne 000 (connexion refusee) malgre docker port mapping OK
- Cause : Gateway bind par defaut sur 127.0.0.1 DANS le container. Docker port mapping necessite 0.0.0.0 interne.
- Diagnostic : /proc/net/tcp montre 0100007F:4965 (127.0.0.1:18789) au lieu de 00000000:4965
- Correction : Ajout gateway.bind=lan + gateway.auth.token dans openclaw.json. Le mode lan force 0.0.0.0 mais exige un token auth.
- Statut : RESOLU
