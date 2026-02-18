# CONSIGNES ABSOLUES — A LIRE AVANT TOUTE ACTION

Ces regles sont IMPLACABLES. Aucune exception. Aucun contournement. JAMAIS.

## !!!! REGLE NUMERO ZERO — WORKFLOW DE MISE A JOUR !!!!
## !!!! TRES TRES TRES IMPORTANT !!!!

**TOUTE modification de fichier doit suivre ce workflow STRICT :**

```
1. MODIFIER EN LOCAL (dans C:\Users\avala\Desktop\cblrs2-vps2\Caballarius-VPS2-18-02-2026\)
2. GIT COMMIT + GIT PUSH vers GitHub (Gerokk1/Caballarius-VPS2-18-02-2026)
3. SUR VPS2 : git pull pour recuperer les changements
```

- Ne JAMAIS modifier directement sur le VPS2 sans passer par git
- Ne JAMAIS push sur git sans avoir modifie en local d'abord
- Le repo local est la SOURCE DE VERITE
- Le VPS2 recoit les mises a jour UNIQUEMENT via git pull
- Si un script doit tourner sur VPS2, il est ecrit en local, pushe, puis pull sur VPS2

**Violation de cette regle = perte de sync = CHAOS. INTERDIT.**

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

## 3. SECURITE — REGLE ABSOLUE : ZERO CREDENTIAL DANS LE CODE

**Ne JAMAIS push/verser de fichier contenant des mots de passe, tokens, ou API keys.**

- Ne JAMAIS ecrire un mot de passe, token, ou API key en dur dans un fichier .py, .js, .json, .sh, .md (sauf BRAIN/CREDENTIALS qui est gitignored)
- Les credentials vont UNIQUEMENT dans :
  - `.env` (gitignored) sur le VPS2
  - `BRAIN/CREDENTIALS/` (gitignored, local uniquement)
  - Variables d'environnement (`os.environ.get("DB_PASS")` etc.)
- AVANT chaque git add/commit : VERIFIER que AUCUN fichier ne contient de credential en clair
- Si un fichier avec credentials est deja dans le repo ou sur le VPS : LE SUPPRIMER IMMEDIATEMENT et le remplacer par une version avec variables d'environnement
- Fichiers a ne JAMAIS push : `.env`, `*.ps1`, `Cblrs-Kraps-2026/`, `BRAIN/CREDENTIALS/`, `BRAIN/CONFIG/`
- UFW doit TOUJOURS etre actif
- Fail2Ban doit TOUJOURS etre actif
- SSH par mot de passe doit etre DESACTIVE

**Violation = fuite de donnees = CATASTROPHE. INTERDIT.**

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
