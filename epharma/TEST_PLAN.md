# Plan de tests global de l'application E-Pharmacie

Ce document regroupe les scripts de test fonctionnels et d'intégration pour l'application E-Pharmacie.

## 1. Tests du Module Client

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TC001 | Inscription | Créer un compte avec des informations valides | Compte créé avec succès | Conforme |
| TC002 | Inscription | Créer un compte avec email existant | Message d'erreur affiché | Conforme |
| TC003 | Inscription | Laisser un champ obligatoire vide | Refus de validation | Conforme |
| TC004 | Connexion | Se connecter avec identifiants valides | Accès au tableau de bord | Conforme |
| TC005 | Connexion | Mot de passe incorrect | Message d'erreur | Conforme |
| TC006 | Déconnexion | Cliquer sur Déconnexion | Retour à la page d'accueil | Conforme |
| TC007 | Catalogue | Consulter la liste des produits | Affichage correct des produits | Conforme |
| TC008 | Recherche | Rechercher un médicament existant | Produit retrouvé | Conforme |
| TC009 | Recherche | Rechercher un produit inexistant | Aucun résultat trouvé | Conforme |
| TC010 | Détails produit | Consulter les détails d'un produit | Informations complètes affichées | Conforme |
| TC011 | Panier | Ajouter un produit au panier | Produit ajouté | Conforme |
| TC012 | Panier | Ajouter plusieurs produits | Tous les produits affichés | Conforme |
| TC013 | Panier | Modifier une quantité | Mise à jour du montant | Conforme |
| TC014 | Panier | Supprimer un produit | Produit retiré | Conforme |
| TC015 | Commande | Valider une commande | Commande enregistrée | Conforme |
| TC016 | Historique | Consulter l'historique des commandes | Historique affiché | Conforme |
| TC017 | Profil | Modifier les informations personnelles | Données mises à jour | Conforme |
| TC018 | Sécurité | Accès à une page protégée sans connexion | Redirection vers connexion | Conforme |

## 2. Tests du Module Pharmacie

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TP001 | Connexion pharmacien | Saisir des identifiants valides | Accès au tableau de bord | Conforme |
| TP002 | Connexion pharmacien | Saisir un mot de passe erroné | Message d'erreur | Conforme |
| TP003 | Gestion produits | Ajouter un produit | Produit enregistré | Conforme |
| TP004 | Gestion produits | Ajouter un produit avec données invalides | Refus de l'enregistrement | Conforme |
| TP005 | Gestion produits | Modifier un produit | Modification enregistrée | Conforme |
| TP006 | Gestion produits | Supprimer un produit | Produit supprimé | Conforme |
| TP007 | Gestion produits | Consulter la liste des produits | Liste affichée | Conforme |
| TP008 | Gestion stock | Consulter le stock | Quantités affichées | Conforme |
| TP009 | Gestion stock | Mettre à jour une quantité | Stock actualisé | Conforme |
| TP010 | Gestion stock | Produit en rupture | Signalement rupture affiché | Conforme |
| TP011 | Gestion catégories | Ajouter une catégorie | Catégorie créée | Conforme |
| TP012 | Gestion catégories | Modifier une catégorie | Catégorie mise à jour | Conforme |
| TP013 | Gestion catégories | Supprimer une catégorie | Catégorie supprimée | Conforme |
| TP014 | Gestion commandes | Consulter les commandes reçues | Liste affichée | Conforme |
| TP015 | Gestion commandes | Accepter une commande | Statut modifié | Conforme |
| TP016 | Gestion commandes | Rejeter une commande | Statut modifié | Conforme |
| TP017 | Gestion commandes | Marquer une commande comme livrée | Statut mis à jour | Conforme |
| TP018 | Gestion clients | Consulter la liste des clients | Liste affichée | Conforme |
| TP019 | Gestion utilisateurs | Ajouter un employé | Employé enregistré | Conforme |
| TP020 | Gestion utilisateurs | Modifier un employé | Modification enregistrée | Conforme |
| TP021 | Gestion utilisateurs | Supprimer un employé | Employé supprimé | Conforme |

## 3. Tests de Communication Client ↔ Pharmacie

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TI001 | Synchronisation commande | Client passe une commande | Visible côté pharmacie | Conforme |
| TI002 | Validation commande | Pharmacie accepte la commande | Client notifié | Conforme |
| TI003 | Refus commande | Pharmacie refuse la commande | Client notifié | Conforme |
| TI004 | Mise à jour stock | Vente d'un produit | Quantité diminuée automatiquement | Conforme |
| TI005 | Historique | Commande validée | Historique synchronisé | Conforme |

## 4. Tests de Base de Données

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TB001 | Création compte | Inscription utilisateur | Enregistrement dans MongoDB | Conforme |
| TB002 | Connexion | Authentification | Vérification des identifiants | Conforme |
| TB003 | Produit | Création produit | Enregistrement correct | Conforme |
| TB004 | Commande | Validation commande | Sauvegarde correcte | Conforme |
| TB005 | Suppression | Suppression produit | Retrait dans la base | Conforme |
| TB006 | Mise à jour | Modification produit | Mise à jour correcte | Conforme |

## 5. Tests de Sécurité

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TS001 | Authentification | Accès sans connexion | Refus d'accès | Conforme |
| TS002 | Gestion rôles | Client accède à l'administration | Refus d'accès | Conforme |
| TS003 | Gestion rôles | Pharmacien accède à son espace | Autorisé | Conforme |
| TS004 | Validation données | Injection de caractères spéciaux | Rejet ou nettoyage | Conforme |
| TS005 | Session | Déconnexion | Session détruite | Conforme |

## 6. Tests de Performance

| N° | Fonctionnalité | Action | Résultat attendu | Statut |
|---|---|---|---|---|
| TF001 | Chargement catalogue | Afficher 100 produits | Temps acceptable | |
| TF002 | Recherche | Rechercher un produit | Réponse rapide | |
| TF003 | Connexion simultanée | Plusieurs utilisateurs connectés | Fonctionnement normal | |
| TF004 | Création commande | Validation commande | Réponse rapide | |
| TF005 | Consultation historique | Affichage des données | Temps acceptable | |

## Résultat global

- Module Client: 18 tests
- Module Pharmacie: 21 tests
- Intégration: 5 tests
- Base de données: 6 tests
- Sécurité: 5 tests
- Performance: 5 tests
- Total: 60 cas de test
