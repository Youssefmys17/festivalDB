DROP DATABASE IF EXISTS festivalDB;
CREATE DATABASE festivalDB;
USE festivalDB;

CREATE TABLE Association (
    numeroSIREN CHAR(9) NOT NULL,
    nomAssociation VARCHAR(120) NOT NULL,
    emailAssociation VARCHAR(254) NOT NULL,
    PRIMARY KEY (numeroSIREN),
    UNIQUE (emailAssociation)
);

CREATE TABLE Festival (
    nomFestival VARCHAR(120) NOT NULL,
    PRIMARY KEY (nomFestival)
);

CREATE TABLE Site (
    nomSite VARCHAR(150) NOT NULL,
    adresseSite VARCHAR(200) NOT NULL,
    communeSite VARCHAR(80) NOT NULL,
    capaciteMaxSite INT NOT NULL,
    PRIMARY KEY (nomSite)
);

CREATE TABLE Artiste (
    nomArtiste VARCHAR(150) NOT NULL,
    paysOrigineArtiste VARCHAR(80) NOT NULL,
    genreMusical VARCHAR(80) NOT NULL,
    emailContactArtiste VARCHAR(254) NOT NULL,
    PRIMARY KEY (nomArtiste),
    UNIQUE (emailContactArtiste)
);

CREATE TABLE Acheteur (
    emailAcheteur VARCHAR(254) NOT NULL,
    nomAcheteur VARCHAR(80) NOT NULL,
    prenomAcheteur VARCHAR(80) NOT NULL,
    telephoneAcheteur VARCHAR(20) NOT NULL,
    PRIMARY KEY (emailAcheteur)
);

CREATE TABLE Edition (
    numeroEdition INT NOT NULL,
    dateDebutEdition DATE NOT NULL,
    dateFinEdition DATE NOT NULL,
    nomFestival VARCHAR(120) NOT NULL,
    nomSite VARCHAR(150) NOT NULL,
    PRIMARY KEY (numeroEdition),
    FOREIGN KEY (nomFestival) REFERENCES Festival(nomFestival)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (nomSite) REFERENCES Site(nomSite)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Scene (
    nomScene VARCHAR(80) NOT NULL,
    capaciteScene INT NOT NULL,
    nomSite VARCHAR(150) NOT NULL,
    PRIMARY KEY (nomScene),
    FOREIGN KEY (nomSite) REFERENCES Site(nomSite)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Jour_de_Festival (
    dateJourFestival DATE NOT NULL,
    numeroEdition INT NOT NULL,
    PRIMARY KEY (dateJourFestival),
    FOREIGN KEY (numeroEdition) REFERENCES Edition(numeroEdition)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Commande (
    referenceCommande VARCHAR(20) NOT NULL,
    dateCommande DATE NOT NULL,
    statutCommande VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    statutPaiement VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    datePaiement DATETIME NULL,
    numeroEdition INT NOT NULL,
    emailAcheteur VARCHAR(254) NOT NULL,
    PRIMARY KEY (referenceCommande),
    FOREIGN KEY (numeroEdition) REFERENCES Edition(numeroEdition)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (emailAcheteur) REFERENCES Acheteur(emailAcheteur)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Ligne_de_Commande (
    referenceCommande VARCHAR(20) NOT NULL,
    numeroLigneCommande INT NOT NULL,
    typeBillet VARCHAR(20) NOT NULL,
    prixUnitaire DECIMAL(8,2) NOT NULL,
    quantite INT NOT NULL DEFAULT 1,
    dateJourFestival DATE NULL,
    PRIMARY KEY (referenceCommande, numeroLigneCommande),
    FOREIGN KEY (referenceCommande) REFERENCES Commande(referenceCommande)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (dateJourFestival) REFERENCES Jour_de_Festival(dateJourFestival)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Organiser (
    numeroSIREN CHAR(9) NOT NULL,
    numeroEdition INT NOT NULL,
    PRIMARY KEY (numeroSIREN, numeroEdition),
    FOREIGN KEY (numeroSIREN) REFERENCES Association(numeroSIREN)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (numeroEdition) REFERENCES Edition(numeroEdition)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Jouer (
    nomArtiste VARCHAR(150) NOT NULL,
    nomScene VARCHAR(80) NOT NULL,
    dateJourFestival DATE NOT NULL,
    heureDebutConcert TIME NOT NULL,
    heureFinConcert TIME NOT NULL,
    montantCachet DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nomArtiste, nomScene, dateJourFestival),
    FOREIGN KEY (nomArtiste) REFERENCES Artiste(nomArtiste)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (nomScene) REFERENCES Scene(nomScene)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (dateJourFestival) REFERENCES Jour_de_Festival(dateJourFestival)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
