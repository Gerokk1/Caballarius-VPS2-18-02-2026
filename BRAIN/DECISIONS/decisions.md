# Decisions Techniques — VPS2

## DEC-001 : Cle SSH a utiliser
- Date : 2026-02-18
- Decision : Utiliser `private-key-kraps.txt` (pas `Kblrs-Kraps.txt`)
- Raison : `Kblrs-Kraps.txt` contient aussi une cle RSA privee mais `private-key-kraps.txt` est celle qui correspond a la cle publique installee sur le serveur
- La cle publique (`public-key-kraps.txt`) correspond a `private-key-kraps.txt`

## DEC-002 : Montage disque 250 Go
- Date : 2026-02-18
- Decision : Le disque est deja monte sur /mnt/data par l'hebergeur. Creer symlink /data -> /mnt/data
- Raison : Pas besoin de repartitionner/reformater, le disque est deja pret. Le symlink /data simplifie les chemins

## DEC-003 : Shell local
- Date : 2026-02-18
- Decision : Utiliser PowerShell pour toutes les commandes locales (bash ne fonctionne pas dans cet environnement)
- Raison : Le shell bash retourne systematiquement exit code 1 sans output. PowerShell fonctionne correctement.
