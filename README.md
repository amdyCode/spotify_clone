# Spotify Clone (Flutter)

Un clone mobile haute fidélité de Spotify développé avec **Flutter** et **GetX**, connecté à l'**API Deezer** pour la recherche en direct, le streaming d'extraits officiels et l'affichage des paroles synchronisées.

---

## Aperçu / Captures d'écran

| Accueil | Recherche | Grand Lecteur | Paroles Synchronisées |
| :---: | :---: | :---: | :---: |
| ![Accueil](screenshots/home.png) | ![Recherche](screenshots/search.png) | ![Grand Lecteur](screenshots/player.png) | ![Paroles](screenshots/lyrics.png) |

---

## Fonctionnalités clés

- **Navigation épurée (3 onglets)** : *Accueil*, *Rechercher*, *Bibliothèque*, avec design sombre fidèle à Spotify.
- **Streaming audio réel (API Deezer)** : Lecture d'extraits officiels 30s en haute qualité (PNL, Ninho, Damso, Soolking, Werenoi...).
- **Recherche en temps réel** : Recherche instantanée connectée au catalogue officiel Deezer.
- **Grand Lecteur immersif** :
  - Décompte exact sur 30s (`0:00` et temps restant `-0:xx`).
  - Badge explicite `[E]`, ajout aux favoris, mode aléatoire et minuterie.
- **Paroles synchronisées** : Affichage plein écran avec défilement automatique, mise en lumière de la ligne chantée et navigation au tap.
- **Mini-lecteur gestuel** : Balayage vers le bas (swipe-down) pour masquer le lecteur et couper le son instantanément sans bug d'arbre de widgets.

---

## Stack

- **State Management :** [GetX](https://pub.dev/packages/get)
- **Audio Engine :** [just_audio](https://pub.dev/packages/just_audio)
- **API :** Deezer API (Search & Track Previews)
- **Cache d'images :** [cached_network_image](https://pub.dev/packages/cached_network_image)
