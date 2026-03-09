# 📊 Tableau de Bord de Guilde – Forge of Empires

Application interactive développée avec **R et Shiny** permettant d’analyser la production de ressources d’une guilde dans *Forge of Empires*.

L’application permet de :

* visualiser la production des joueurs
* analyser la production par ère
* comparer l’évolution du stock de ressources
* détecter automatiquement des alertes (joueurs ou ressources faibles)

---

# 📌 Fonctionnalités

L’application se compose de  **5 modules principaux** :

### 1️⃣ Import des données

* Import de fichiers CSV exportés du jeu
* Aperçu rapide des données importées
* Gestion de plusieurs fichiers :

  * `GuildBuildings`
  * `GuildGoods Maintenant`
  * `GuildGoods Avant`

---

### 2️⃣ Analyse de la production par joueur

Pour chaque membre de la guilde :

* graphique de production par **ère**
* tableau détaillé des ressources produites
* classement global des joueurs

Visualisation incluse :

* **graphique en barres**
* **tableaux interactifs**

---

### 3️⃣ Analyse de la production par ère

Ce module permet de :

* voir la **production totale de chaque ère**
* afficher le **classement des joueurs pour une ère donnée**
* visualiser la production sous forme de graphique

Fonctionnalités :

* 'sélection dynamique de l’ère
* calcul automatique des totaux

---

### 4️⃣ Analyse de l’évolution du stock

Comparaison entre :

* **stock actuel**
* **stock précédent**

Calcul automatique :

* gains de ressources
* pertes de ressources

Affichage :

* graphique des pertes
* tableau des gains
* tableau des pertes

---

### 5️⃣ Système d’alertes

Ce module détecte automatiquement :

#### Ressources faibles

Les ressources dont le stock est inférieur à un seuil défini (300 000 la valeur par defaut).

#### Joueurs peu actifs

Les joueurs dont la production totale est inférieure à un seuil(8000 la valeur par defaut).

Les seuils sont ajustables avec des **sliders interactifs**.

---

# 📁 Structure du projet

```text
project/
│
├── app.R                  # Application Shiny principale
├── README.md              # Documentation du projet
├── description.txt        # Description du projet       
├── GuildBuildings.csv     # fichier csv avec l ensemble des batiments de la guilde
├── GuildGoods_maintenant.csv     # Fichier csv avec les ressources de la guilde actuellement 
└── GuildGoods_avant.csv          # Fichier csv avecldes ressources de la guilde precedement  
```

---

# ⚙️ Installation

## 1️⃣ Installer R et RStudio

Installer :

* R
* RStudio

---

## 2️⃣ Installer les packages nécessaires

Dans la console R :

```r
install.packages(c("shiny","dplyr","ggplot2","DT"))
```

---

# 🚀 Lancer l'application

Depuis **RStudio** :

```r
library(shiny)
runApp()
```

Ou ouvrir le fichier :

```
app.R
```

et cliquer sur **Run App**.

---

# 📂 Format des données attendues

## GuildBuildings.csv

Colonnes nécessaires :

| Colonne    | Description          |
| ---------- | -------------------- |
| building   | nom du batiment      |
| member     | nom du joueur        |
| era        | ère du bâtiment      |
| eraID      | identifiant de l’ère |
| guildGoods | ressources produites |

---

## GuildGoods Maintenant / Avant

Colonnes nécessaires :

| Colonne | Description          |
| ------- | -------------------- |
| eraID   | identifiant de l’ère |
| era     | nom de l’ère         |
| good    | nom de la ressource  |
| instock | quantité stockée     |

---

# 📊 Technologies utilisées

* **R**
* **Shiny** (applications web interactives)
* **dplyr** (manipulation de données)
* **ggplot2** (visualisation graphique)
* **DT** (tables interactives)

---

# 🎯 Objectif du projet

Ce projet a été réalisé  afin de :

* manipuler des données réelles
* créer une application interactive
* développer des compétences en **data visualisation**
* apprendre le développement avec **Shiny**

---

# 🔧 Améliorations possibles

* Rendre l’interface plus agréable à regarder (ajout de thèmes, d’emojis et de couleurs)
* export des résultats en **CSV / Excel**
* ajout d’un **dashboard global**
* ajout d une verification lors de l ajout des fichiers
  

---

# 👤 Auteur

**Olivier Gabriel**

Projet personnel réalisé avec **R et Shiny**.


