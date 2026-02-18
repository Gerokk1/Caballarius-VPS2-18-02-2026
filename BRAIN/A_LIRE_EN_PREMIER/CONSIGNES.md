# CONSIGNES ABSOLUES — A LIRE AVANT TOUTE ACTION

Ces regles sont IMPLACABLES. Aucune exception. Aucun contournement. JAMAIS.

## 1. SEPARATION VPS1 / VPS2
- VPS1 (caballarius.eu) = Plateforme pelerin. NE JAMAIS TOUCHER.
- VPS2 (cblrs.net) = Usine a contenu + hebergeur sites pros. C'est ICI qu'on travaille.
- Ne JAMAIS modifier le repo VPS1 : Gerokk1/Caballarius-2-15-02-2026
- Ne JAMAIS toucher au dossier local C:\Users\avala\Desktop\Cblrs3-vps1

## 2. BRAIN OBLIGATOIRE
- Toute action doit etre loguee dans CHRONOLOGIE avec horodatage [YYYY-MM-DD HH:MM]
- Tout bug doit etre logue dans BUGS + CHRONOLOGIE
- Toute decision technique doit etre loguee dans DECISIONS + CHRONOLOGIE
- STATE.md doit TOUJOURS etre a jour apres chaque etape
- JAMAIS de fichiers de memoire en dehors de BRAIN

## 3. SECURITE
- Ne JAMAIS exposer les credentials en clair dans le code pushe sur GitHub
- Les mots de passe et tokens vont dans .env (gitignored) et dans BRAIN/CONFIG (local uniquement)
- UFW doit TOUJOURS etre actif
- Fail2Ban doit TOUJOURS etre actif
- SSH par mot de passe doit etre DESACTIVE

## 4. STRUCTURE DISQUE
- Tout le contenu sur /data (disque 250 Go)
- /data/sites/ = sites des pros
- /data/n8n/ = donnees n8n
- /data/backups/ = sauvegardes
- /data/templates/ = templates sites pros
- Ne JAMAIS stocker de donnees volumineuses sur le disque systeme

## 5. AVANT CHAQUE NOUVEAU CHAT
- Lire A_LIRE_EN_PREMIER/CONSIGNES.md
- Lire STATE.md
- Lire le dernier fichier dans CHRONOLOGIE
- Seulement ENSUITE commencer a travailler

## 6. DEPLOIEMENT
- Toujours tester avant de deployer
- Toujours avoir un backup avant une modification majeure
- Toujours loguer dans CHRONOLOGIE avant ET apres un deploiement
