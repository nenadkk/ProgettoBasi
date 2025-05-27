CREATE TABLE Persona(
    codice_fiscale CHAR(16) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL
);

CREATE TABLE Prodotto(
    seriale CHAR(12) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    valutazione INT NOT NULL,
    prezzo_mercato INT NOT NULL,

    CHECK (valutazione > 0),
    CHECK (prezzo_mercato > 0), 
    CHECK (seriale ~ '^[0-9]{12}$')
);

CREATE TABLE Possesso(
    proprietario CHAR(16),
    prodotto CHAR(12),
    data_inizio DATE NOT NULL,
    data_fine DATE DEFAULT NULL,

    CHECK (data_fine IS NULL OR data_fine > data_inizio),

    PRIMARY KEY (prodotto, data_inizio),
   
    FOREIGN KEY(proprietario) REFERENCES Persona(codice_fiscale),
    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale)
);

CREATE TABLE Certificatore(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    tipologia VARCHAR(100) NOT NULL,

    CHECK (partita_iva ~ '^[0-9]{11}$')
);

CREATE TABLE Banditore(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    esperienza SMALLINT NOT NULL,

    CHECK (partita_iva ~ '^[0-9]{11}$')
);

CREATE TABLE Sponsor(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    tipologia VARCHAR(100) NOT NULL,
    livello VARCHAR(100) NOT NULL,

    CHECK (partita_iva ~ '^[0-9]{11}$')
);

CREATE TABLE Asta(
    codice_asta CHAR(12) PRIMARY KEY,
    prodotto CHAR(12),
    banditore CHAR(11),
    data_inizio DATE NOT NULL,
    data_fine DATE DEFAULT NULL,
    base_asta INT NOT NULL,
    importo_offerta_vincente INT DEFAULT NULL,
    num_partecipanti INT DEFAULT 0,
    sponsor CHAR(11) DEFAULT NULL,

    CHECK (codice_asta ~ '^[0-9]{12}$'),
    CHECK (base_asta > 0),

    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale),
    FOREIGN KEY(banditore) REFERENCES Banditore(partita_iva),
    FOREIGN KEY(sponsor) REFERENCES Sponsor(partita_iva)
);

CREATE TABLE Offerta(
    asta CHAR(12),
    offerente CHAR(16),
    orario_offerta TIMESTAMP NOT NULL,
    importo INT NOT NULL,

    PRIMARY KEY(asta, orario_offerta),
    FOREIGN KEY(asta) REFERENCES Asta(codice_asta),
    FOREIGN KEY(offerente) REFERENCES Persona(codice_fiscale)
);

CREATE TABLE Autenticazione(
    codice_autenticante CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR(100) NOT NULL,
    prodotto CHAR(12) UNIQUE,
    data_emanazione DATE NOT NULL,
    tecnica_analisi VARCHAR(100) NOT NULL,

    CHECK (codice ~ '^[0-9]{12}$'),

    PRIMARY KEY (codice_autenticante, certificatore),
    FOREIGN KEY(certificatore) REFERENCES Certificatore(partita_iva),
    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale)
);

CREATE TABLE Specializzazione(
    codice_specializzante CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR(100) NOT NULL,
    data_emanazione DATE NOT NULL,
    livello VARCHAR(100) NOT NULL,
    
    CHECK (codice ~ '^[0-9]{12}$'),

    PRIMARY KEY (codice_specializzante, certificatore),
    FOREIGN KEY(certificatore) REFERENCES Certificatore(partita_iva)
);

CREATE TABLE Competenza(
    certificatore CHAR(11),
    codice_specializzazione CHAR(12),
    banditore CHAR(11),
    data_specializzazione DATE NOT NULL,
    
    PRIMARY KEY (codice_specializzazione, certificatore, banditore),
    FOREIGN KEY (codice_specializzazione, certificatore) 
        REFERENCES Specializzazione(codice_specializzante, certificatore),
    FOREIGN KEY(banditore) REFERENCES Banditore(partita_iva)
);