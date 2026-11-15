USE festivalDB;

-- Projections et sélections

-- Liste sans doublon des pays d'origine des artistes par ordre alphabétique
SELECT DISTINCT paysOrigineArtiste
FROM Artiste
ORDER BY paysOrigineArtiste ASC;

-- Artistes appartenant aux genres Rock, Metal ou Punk triés par genre et nom
SELECT nomArtiste, genreMusical, paysOrigineArtiste, emailContactArtiste
FROM Artiste
WHERE genreMusical IN ('Rock', 'Metal', 'Punk')
ORDER BY genreMusical ASC, nomArtiste ASC;

-- Concerts dont le cachet est compris entre 30 000 € et 50 000 € par cachet décroissant
SELECT nomArtiste, nomScene, dateJourFestival, heureDebutConcert, montantCachet
FROM Jouer
WHERE montantCachet BETWEEN 30000.00 AND 50000.00
ORDER BY montantCachet DESC;

-- Acheteurs ayant un numéro international (commençant par +) ou une adresse Gmail
SELECT nomAcheteur, prenomAcheteur, emailAcheteur, telephoneAcheteur
FROM Acheteur
WHERE telephoneAcheteur LIKE '+%'
   OR emailAcheteur LIKE '%@gmail.com'
ORDER BY nomAcheteur ASC, prenomAcheteur ASC;

-- Commandes de l'édition 2026 (masque CMD-2026-___) dont le paiement n'est pas encore encaissé
SELECT referenceCommande, dateCommande, statutCommande, statutPaiement, emailAcheteur
FROM Commande
WHERE referenceCommande LIKE 'CMD-2026-___'
  AND datePaiement IS NULL
ORDER BY dateCommande ASC;

-- Scènes ayant une capacité d'accueil comprise entre 5 000 et 30 000 places
SELECT nomScene, nomSite, capaciteScene
FROM Scene
WHERE capaciteScene BETWEEN 5000 AND 30000
ORDER BY capaciteScene DESC;

-- Fonctions d'agrégation avec GROUP BY et HAVING

-- Nombre de concerts, budget total, cachet moyen, minimum et maximum par édition
SELECT jdf.numeroEdition,
       COUNT(*) AS nbConcerts,
       SUM(j.montantCachet) AS budgetTotalCachets,
       AVG(j.montantCachet) AS cachetMoyen,
       MIN(j.montantCachet) AS cachetMin,
       MAX(j.montantCachet) AS cachetMax
FROM Jouer j
JOIN Jour_de_Festival jdf ON j.dateJourFestival = jdf.dateJourFestival
GROUP BY jdf.numeroEdition
ORDER BY jdf.numeroEdition ASC;

-- Genres musicaux totalisant au moins 4 concerts programmés et leur cachet moyen
SELECT a.genreMusical,
       COUNT(*) AS nbConcertsProgrammes,
       AVG(j.montantCachet) AS cachetMoyenGenre
FROM Artiste a
JOIN Jouer j ON a.nomArtiste = j.nomArtiste
GROUP BY a.genreMusical
HAVING COUNT(*) >= 4
ORDER BY cachetMoyenGenre DESC;

-- Chiffre d'affaires encaissé et billets vendus par édition dépassant 2 500 € de recettes
SELECT c.numeroEdition,
       COUNT(DISTINCT c.referenceCommande) AS nbCommandesPayees,
       SUM(lc.quantite) AS totalBilletsVendus,
       SUM(lc.quantite * lc.prixUnitaire) AS chiffreAffairesEncaisse
FROM Commande c
JOIN Ligne_de_Commande lc ON c.referenceCommande = lc.referenceCommande
WHERE c.statutPaiement = 'paye'
GROUP BY c.numeroEdition
HAVING SUM(lc.quantite * lc.prixUnitaire) > 2500.00
ORDER BY chiffreAffairesEncaisse DESC;

-- Artistes programmés lors d'au moins 2 concerts et dont le cumul de cachets dépasse 60 000 €
SELECT nomArtiste,
       COUNT(*) AS nbPrestations,
       SUM(montantCachet) AS cumulCachets
FROM Jouer
GROUP BY nomArtiste
HAVING COUNT(*) >= 2
   AND SUM(montantCachet) > 60000.00
ORDER BY cumulCachets DESC;

-- Nombre de billets écoulés et recette totale par type de billet ayant écoulé au moins 15 billets payés
SELECT lc.typeBillet,
       COUNT(*) AS nbLignesCommande,
       SUM(lc.quantite) AS nbBilletsEcoules,
       SUM(lc.quantite * lc.prixUnitaire) AS recetteTotale
FROM Ligne_de_Commande lc
JOIN Commande c ON lc.referenceCommande = c.referenceCommande
WHERE c.statutPaiement = 'paye'
GROUP BY lc.typeBillet
HAVING SUM(lc.quantite) >= 15
ORDER BY recetteTotale DESC;

-- Acheteurs dont le montant total dépensé en commandes payées est d'au moins 700 €
SELECT a.emailAcheteur,
       a.nomAcheteur,
       a.prenomAcheteur,
       COUNT(DISTINCT c.referenceCommande) AS nbCommandesPayees,
       SUM(lc.quantite * lc.prixUnitaire) AS montantTotalDepense
FROM Acheteur a
JOIN Commande c ON a.emailAcheteur = c.emailAcheteur
JOIN Ligne_de_Commande lc ON c.referenceCommande = lc.referenceCommande
WHERE c.statutPaiement = 'paye'
GROUP BY a.emailAcheteur, a.nomAcheteur, a.prenomAcheteur
HAVING SUM(lc.quantite * lc.prixUnitaire) >= 700.00
ORDER BY montantTotalDepense DESC;

-- Jointures internes, externes, simples et multiples

-- Scènes accompagnées de la commune et de la capacité maximale de leur site
SELECT sc.nomScene,
       sc.capaciteScene,
       si.nomSite,
       si.communeSite,
       si.capaciteMaxSite
FROM Scene sc
JOIN Site si ON sc.nomSite = si.nomSite
ORDER BY si.nomSite ASC, sc.capaciteScene DESC;

-- Programmation complète de l'édition 2026 (date, horaires, scène, artiste, genre et commune)
SELECT jdf.dateJourFestival,
       j.heureDebutConcert,
       j.heureFinConcert,
       j.nomScene,
       a.nomArtiste,
       a.genreMusical,
       si.communeSite
FROM Edition e
JOIN Site si ON e.nomSite = si.nomSite
JOIN Jour_de_Festival jdf ON e.numeroEdition = jdf.numeroEdition
JOIN Jouer j ON jdf.dateJourFestival = j.dateJourFestival
JOIN Artiste a ON j.nomArtiste = a.nomArtiste
WHERE e.numeroEdition = 2026
ORDER BY jdf.dateJourFestival ASC, j.heureDebutConcert ASC;

-- Nom, heure de début et cachet des artistes Electro jouant sur une scène de capacité > 20 000
SELECT a.nomArtiste,
       j.heureDebutConcert,
       j.montantCachet
FROM Artiste a
JOIN Jouer j ON a.nomArtiste = j.nomArtiste
JOIN Scene s ON j.nomScene = s.nomScene
WHERE a.genreMusical = 'Electro'
  AND s.capaciteScene > 20000;

-- Tous les artistes du catalogue ainsi que leurs éventuels concerts programmés
SELECT a.nomArtiste,
       a.genreMusical,
       a.paysOrigineArtiste,
       j.dateJourFestival,
       j.nomScene,
       j.montantCachet
FROM Artiste a
LEFT JOIN Jouer j ON a.nomArtiste = j.nomArtiste
ORDER BY j.dateJourFestival ASC, a.nomArtiste ASC;

-- Toutes les scènes répertoriées ainsi que les concerts qui s'y déroulent
SELECT s.nomScene,
       s.nomSite,
       s.capaciteScene,
       j.nomArtiste,
       j.dateJourFestival
FROM Jouer j
RIGHT JOIN Scene s ON j.nomScene = s.nomScene
ORDER BY j.nomArtiste ASC, s.nomScene ASC, j.dateJourFestival ASC;

-- Détail des lignes de commandes confirmées de 2026 avec acheteur et jour éventuel concerné
SELECT c.referenceCommande,
       ac.nomAcheteur,
       ac.prenomAcheteur,
       lc.numeroLigneCommande,
       lc.typeBillet,
       lc.quantite,
       lc.prixUnitaire,
       jdf.dateJourFestival
FROM Commande c
JOIN Acheteur ac ON c.emailAcheteur = ac.emailAcheteur
JOIN Ligne_de_Commande lc ON c.referenceCommande = lc.referenceCommande
LEFT JOIN Jour_de_Festival jdf ON lc.dateJourFestival = jdf.dateJourFestival
WHERE c.numeroEdition = 2026
  AND c.statutCommande = 'confirmee'
ORDER BY c.referenceCommande ASC, lc.numeroLigneCommande ASC;

-- Requêtes imbriquées avec IN, NOT IN, EXISTS, NOT EXISTS, ANY, ALL

-- Coordonnées des artistes programmés lors de l'édition 2026
SELECT nomArtiste, genreMusical, paysOrigineArtiste, emailContactArtiste
FROM Artiste
WHERE nomArtiste IN (
    SELECT j.nomArtiste
    FROM Jouer j
    JOIN Jour_de_Festival jdf ON j.dateJourFestival = jdf.dateJourFestival
    WHERE jdf.numeroEdition = 2026
)
ORDER BY nomArtiste ASC;

-- Artistes du catalogue n'ayant jamais été programmés sur aucune édition
SELECT nomArtiste, genreMusical, paysOrigineArtiste, emailContactArtiste
FROM Artiste
WHERE nomArtiste NOT IN (
    SELECT DISTINCT nomArtiste
    FROM Jouer
)
ORDER BY nomArtiste ASC;

-- Acheteurs ayant commandé au moins un PassFestival dans une commande payée
SELECT ac.emailAcheteur, ac.nomAcheteur, ac.prenomAcheteur, ac.telephoneAcheteur
FROM Acheteur ac
WHERE EXISTS (
    SELECT 1
    FROM Commande c
    JOIN Ligne_de_Commande lc ON c.referenceCommande = lc.referenceCommande
    WHERE c.emailAcheteur = ac.emailAcheteur
      AND c.statutPaiement = 'paye'
      AND lc.typeBillet = 'PassFestival'
)
ORDER BY ac.nomAcheteur ASC;

-- Acheteurs inscrits n'ayant encore passé aucune commande
SELECT ac.emailAcheteur, ac.nomAcheteur, ac.prenomAcheteur, ac.telephoneAcheteur
FROM Acheteur ac
WHERE NOT EXISTS (
    SELECT 1
    FROM Commande c
    WHERE c.emailAcheteur = ac.emailAcheteur
)
ORDER BY ac.nomAcheteur ASC;

-- Concerts dont le cachet dépasse au moins un cachet versé à un artiste Metal
SELECT nomArtiste, nomScene, dateJourFestival, montantCachet
FROM Jouer
WHERE montantCachet > ANY (
    SELECT j.montantCachet
    FROM Jouer j
    JOIN Artiste a ON j.nomArtiste = a.nomArtiste
    WHERE a.genreMusical = 'Metal'
)
ORDER BY montantCachet DESC;

-- Concert(s) ayant le cachet le plus élevé de toute la base
SELECT nomArtiste, nomScene, dateJourFestival, montantCachet
FROM Jouer
WHERE montantCachet >= ALL (
    SELECT montantCachet
    FROM Jouer
)
ORDER BY dateJourFestival ASC;
