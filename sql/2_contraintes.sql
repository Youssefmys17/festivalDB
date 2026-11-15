USE festivalDB;

ALTER TABLE Association
    ADD CONSTRAINT chk_association_siren_format
        CHECK (numeroSIREN LIKE '_________'),
    ADD CONSTRAINT chk_association_nom_non_vide
        CHECK (nomAssociation <> ''),
    ADD CONSTRAINT chk_association_email_format
        CHECK (emailAssociation LIKE '%_@_%._%');

ALTER TABLE Festival
    ADD CONSTRAINT chk_festival_nom_non_vide
        CHECK (nomFestival <> '');

ALTER TABLE Site
    ADD CONSTRAINT chk_site_capacite_intervalle
        CHECK (capaciteMaxSite BETWEEN 100 AND 999999),
    ADD CONSTRAINT chk_site_adresse_commune_non_vides
        CHECK (adresseSite <> '' AND communeSite <> '');

ALTER TABLE Edition
    ADD CONSTRAINT chk_edition_annee_intervalle
        CHECK (numeroEdition BETWEEN 1990 AND 2100),
    ADD CONSTRAINT chk_edition_dates_coherentes
        CHECK (dateFinEdition >= dateDebutEdition);

ALTER TABLE Scene
    ADD CONSTRAINT chk_scene_nom_non_vide
        CHECK (nomScene <> ''),
    ADD CONSTRAINT chk_scene_capacite_intervalle
        CHECK (capaciteScene BETWEEN 50 AND 999999);

ALTER TABLE Artiste
    ADD CONSTRAINT chk_artiste_nom_pays_non_vides
        CHECK (nomArtiste <> '' AND paysOrigineArtiste <> ''),
    ADD CONSTRAINT chk_artiste_genre_valide
        CHECK (genreMusical IN (
            'Rock', 'Metal', 'Electro', 'Pop', 'Indie',
            'Hip-Hop', 'Punk', 'Jazz-Fusion', 'Folk', 'Alternative'
        )),
    ADD CONSTRAINT chk_artiste_email_format
        CHECK (emailContactArtiste LIKE '%_@_%._%');

ALTER TABLE Jouer
    ADD CONSTRAINT chk_jouer_horaires_coherents
        CHECK (heureFinConcert > heureDebutConcert),
    ADD CONSTRAINT chk_jouer_cachet_positif
        CHECK (montantCachet >= 0);

ALTER TABLE Acheteur
    ADD CONSTRAINT chk_acheteur_email_format
        CHECK (emailAcheteur LIKE '%_@_%._%'),
    ADD CONSTRAINT chk_acheteur_identite_non_vide
        CHECK (nomAcheteur <> '' AND prenomAcheteur <> ''),
    ADD CONSTRAINT chk_acheteur_telephone_format
        CHECK (telephoneAcheteur LIKE '0_________' OR telephoneAcheteur LIKE '+%');

ALTER TABLE Commande
    ADD CONSTRAINT chk_commande_reference_masque
        CHECK (referenceCommande LIKE 'CMD-%'),
    ADD CONSTRAINT chk_commande_statut_valide
        CHECK (statutCommande IN ('en_attente', 'confirmee', 'annulee')),
    ADD CONSTRAINT chk_commande_statut_paiement_valide
        CHECK (statutPaiement IN ('en_attente', 'paye', 'refuse', 'rembourse')),
    ADD CONSTRAINT chk_commande_coherence_paiement
        CHECK (
            (statutPaiement IN ('en_attente', 'refuse') AND datePaiement IS NULL)
            OR
            (statutPaiement IN ('paye', 'rembourse') AND datePaiement IS NOT NULL AND datePaiement >= dateCommande)
        );

ALTER TABLE Ligne_de_Commande
    ADD CONSTRAINT chk_ligne_numero_intervalle
        CHECK (numeroLigneCommande BETWEEN 1 AND 999),
    ADD CONSTRAINT chk_ligne_type_billet_valide
        CHECK (typeBillet IN ('Journee', 'PassFestival')),
    ADD CONSTRAINT chk_ligne_prix_positif
        CHECK (prixUnitaire > 0),
    ADD CONSTRAINT chk_ligne_quantite_positive
        CHECK (quantite BETWEEN 1 AND 999);
