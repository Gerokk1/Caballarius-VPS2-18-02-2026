# Taches — VPS2

## Terminees
- [x] Etape 1 : Verifier connexion SSH — OK
- [x] Etape 1.5 : Creer le BRAIN — OK
- [x] Etape 2 : Monter le disque 250 Go — OK (symlink /data -> /mnt/data, fstab OK)
- [x] Etape 3 : Securiser le serveur — OK (UFW, Fail2Ban, SSH hardening, unattended upgrades)
- [x] Etape 4 : Installer la stack — OK (Nginx, PHP 8.3, MariaDB, Redis, Node.js 20, Composer, Docker, Certbot)
- [x] Etape 5 : Configurer Nginx wildcard — OK (3 vhosts, SSL en attente)
- [x] Etape 6 : Installer n8n via Docker — OK (container UP, localhost:5678)
- [x] Etape 7 : Preparer structure sites pros — OK (/data/sites, templates, backups)
- [x] Etape 8 : Configurer le repo GitHub — OK (projet propre, BRAIN inclus)
- [x] Etape 9 : Verifications finales — OK (tous services actifs, tests locaux 200)

## En attente (action utilisateur requise)
- [ ] Ouvrir ports 80/443 chez l'hebergeur
- [ ] Corriger DNS www.cblrs.net -> 83.228.211.132
- [ ] Ajouter DNS wildcard *.cblrs.net -> 83.228.211.132
- [ ] Ajouter DNS n8n.cblrs.net -> 83.228.211.132
- [ ] SSL : lancer certbot une fois les ports ouverts
- [ ] Ajouter jails Fail2Ban Nginx (apres premiers logs generes)
