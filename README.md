# Quelle coupe pour Paul ?

Mini-jeu web statique : tes amis reçoivent un lien, votent en duels successifs entre des
photos de coupes de cheveux, et t'envoient un verdict personnel en une action.

## Mode d'emploi (pour Paul)

### 1. Déposer les photos

Mets tes photos de coupes dans `photos-source/`, sous n'importe quel nom, aux formats
`.jpg`, `.jpeg`, `.png` ou `.heic`. L'ordre alphabétique des noms de fichiers détermine
l'ordre de numérotation (N°01, N°02, …), donc renomme-les si tu veux un ordre précis
(ex. `01-undercut.jpg`, `02-buzz.jpg`, …).

Le jeu fonctionne avec **4 à 40 photos**.

### 2. Générer les images du jeu

Il faut [ImageMagick](https://imagemagick.org). S'il n'est pas installé :

```bash
brew install imagemagick
```

Puis, à la racine du projet :

```bash
bash scripts/preparer-images.sh
```

Le script vide `images/`, convertit chaque photo (rotation corrigée, 900 px de large,
WebP qualité 78) et écrit `images/manifest.json`. Il affiche à la fin le nombre de
propositions et le poids total du dossier — vise moins de 4 Mo.

### 3. Publier sur GitHub Pages

Commit les dossiers `images/`, `scripts/`, `index.html`, `.gitignore` et `README.md` (les
photos brutes de `photos-source/` sont ignorées automatiquement, elles ne partent pas dans
le dépôt). Active GitHub Pages sur la branche du dépôt. Le lien du jeu, c'est l'URL que
GitHub Pages te donne.

Une fois le site en ligne, complète l'aperçu du lien (utile pour WhatsApp) : dans
`index.html`, décommente et renseigne la balise `og:image` avec l'URL absolue d'une image,
par exemple `https://TON-COMPTE.github.io/TON-DEPOT/images/coupe-01.webp`. WhatsApp ignore
les chemins relatifs, il faut une URL complète.

### 4. Refaire un tournoi / changer des photos

Dans deux ans, pour changer trois photos : remplace ou ajoute des fichiers dans
`photos-source/`, relance `bash scripts/preparer-images.sh`, recommit `images/`. Tout le
reste (`index.html`, `scripts/`) n'a pas besoin d'être touché.

## Comment ça marche

- Élimination directe simple, plus une petite finale entre les deux perdants des
  demi-finales pour désigner la 3e place. Pour **N** propositions, il y a **N duels** au
  total (N ≥ 4). En dessous de 4 propositions, il n'y a pas de petite finale ni de 3e place.
- Le tableau est mélangé aléatoirement à chaque partie : deux amis n'auront pas forcément
  les mêmes duels ni le même verdict.
- Aucune donnée n'est stockée : pas de backend, pas de `localStorage`, pas d'agrégation des
  votes. Chaque session est indépendante. Recharger la page = nouvelle partie.
- Le verdict final est un PNG généré dans le navigateur, que la personne t'envoie
  manuellement (partage natif sur mobile, téléchargement sur desktop).

## Environnements où le bouton de partage ne se comporte pas comme sur mobile HTTPS

À garder en tête pour éviter les fausses alertes :

- **`http://` ou `file://`** : `navigator.share` n'existe pas hors contexte sécurisé
  (HTTPS). GitHub Pages sert en HTTPS, donc en production ce n'est pas un problème — mais
  en testant le fichier en local sans serveur, le partage natif ne s'activera pas.
- **Iframe sandboxée** (aperçu d'artefact, certains navigateurs intégrés type webview) :
  le partage n'est pas délégué et le téléchargement peut être bloqué. Dans ce cas le jeu
  affiche l'image directement à l'écran avec la consigne « Appuie longuement pour
  l'enregistrer ».
- **Chrome desktop macOS** : le partage natif de fichiers n'est pas disponible, le bouton
  télécharge directement le PNG. C'est le comportement attendu, pas un bug.

## Ce que ce projet ne fait pas (volontairement)

Pas d'agrégation ni de classement des votes, pas de comptes, pas de double élimination ni
de classement Elo, pas d'animations de transition entre duels, pas de mode sombre, pas de
PWA. Voir `BRIEF.md` original pour le détail des choix.

## Arborescence

```
/
├── index.html              # toute l'application : markup, CSS, JS
├── photos-source/          # dépôt de tes JPG/PNG/HEIC bruts (hors dépôt Git)
├── images/                 # généré par le script, versionné, servi par Pages
│   ├── coupe-01.webp
│   ├── ...
│   └── manifest.json
├── scripts/
│   └── preparer-images.sh
├── .gitignore
└── README.md
```
