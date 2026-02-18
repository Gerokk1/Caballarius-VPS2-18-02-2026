# ETAT ACTUEL DU PROJET — VPS2

**Derniere mise a jour : 2026-02-18 14:40**

## Resume
Configuration du VPS2 (cblrs.net) en cours. Serveur accessible en SSH. Disque 250 Go deja monte par l'hebergeur sur /mnt/data. BRAIN cree.

## Ce qui est fait
- Repo GitHub cree : Gerokk1/Caballarius-VPS2-18-02-2026 (vide, a initialiser)
- Connexion SSH validee (ubuntu@83.228.211.132:22 avec private-key-kraps.txt)
- Disque 250 Go detecte (/dev/sdb monte sur /mnt/data, 233 Go libres)
- Structure BRAIN creee avec toutes les regles

## Ce qui est en cours
- Etape 2 : Finaliser le montage disque (symlink /data, verifier fstab)

## Ce qui reste
- Etapes 3 a 9 (securisation, stack, nginx wildcard, n8n, sites pros, repo, verifications)

## Etat du serveur
- OS : Ubuntu, kernel 6.8.0-71-generic
- Rien installe encore (serveur vierge)
- Disque data monte mais pas de symlink /data
- Pas de firewall configure
- Pas de stack installee

## Points d'attention
- Bash ne fonctionne pas en local -> utiliser PowerShell
- Le repo GitHub contient le code du VPS1 clone par erreur -> a vider et reinitialiser
- Le dossier CONFIG ne doit PAS etre commite (credentials)
