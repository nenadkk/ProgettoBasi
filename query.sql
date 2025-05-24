--tutti i nomi di tabelle sono con l'iniziale maiuscole e il resto minuscolo
--tutti gli attributi sono in minuscolo 

CREATE TABLE Persona(
    codice_fiscale CHAR(16) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL
);

CREATE TABLE Certificatore(
    p_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    tipologia VARCHAR(100) NOT NULL,

    CHECK (p_iva ~ '^[0-9]{11}$') --controlla che sia di 11 caratteri numerici
);

CREATE TABLE Banditore(
    p_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    esperienza SMALLINT NOT NULL,

    CHECK (p_iva ~ '^[0-9]{11}$')
);

CREATE TABLE Sponsor(
    p_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    tipologia VARCHAR(100) NOT NULL,
    livello VARCHAR(100) NOT NULL,

    CHECK (p_iva ~ '^[0-9]{11}$')
);

CREATE TABLE Prodotto(
    seriale CHAR(12) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    valutazione INT NOT NULL,
    prezzo_mercato INT NOT NULL,

    CHECK (valutazione>0), --un prodotto non può avere valutazione negativa
    CHECK (prezzo_mercato>0), --un prodotto non può avere prezzo di mercato negativo
    CHECK (seriale ~ '^[0-9]{12}$')
);

CREATE TABLE Possesso(
    prodotto CHAR(12),
    data_inizio DATETIME,
    data_fine DATETIME,
    proprietario CHAR(16),

    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale),
    FOREIGN KEY(proprietario) REFERENCES Persona(codice_fiscale),

    CONSTRAINT PK_Possesso PRIMARY KEY(prodotto,data_inizio)
);

CREATE TABLE Autenticazione(
    codice CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR(100) NOT NULL,
    prodotto CHAR(12),
    data_emanazione DATE NOT NULL,
    tecnica_analisi VARCHAR(100) NOT NULL,

    CHECK (codice ~ '^[0-9]{12}$'),

    FOREIGN KEY(certificatore) REFERENCES Certificatore(p_iva),
    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale),

    CONSTRAINT PK_Autenticazione PRIMARY KEY(codice,certificatore)
);

CREATE TABLE Specializzazione(
    codice CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR(100) NOT NULL,
    data_emanazione DATE NOT NULL,
    livello VARCHAR(100) NOT NULL,
    
    CHECK (codice ~ '^[0-9]{12}$'),
    FOREIGN KEY(certificatore) REFERENCES Certificatore(p_iva),

    CONSTRAINT PK_Specializzazione PRIMARY KEY(codice,certificatore)
);

CREATE TABLE Competenza(
    certificatore CHAR(11),
    codice_specializzazione CHAR(12),
    banditore CHAR(11),
    data_specializzazione DATE NOT NULL,

    FOREIGN KEY(certificatore) REFERENCES Specializzazione(certificatore),
    FOREIGN KEY(codice_specializzazione) REFERENCES Specializzazione(codice),
    FOREIGN KEY(banditore) REFERENCES Banditore(p_iva),

    CONSTRAINT PK_Competenza PRIMARY KEY(certificatore, codice_specializzazione, banditore)

);

CREATE TABLE Asta(
    codice CHAR(12) PRIMARY KEY,
    prodotto CHAR(12),
    banditore CHAR(11),
    data_inizio DATE NOT NULL,
    data_fine DATE DEFAULT NULL,
    base_asta INT NOT NULL,
    dataOra_offerta_vincente DATETIME,
    num_partecipanti INT DEFAULT 0,
    sponsor CHAR(11),

    CHECK (codice ~ '^[0-9]{12}$'),
    CHECK (base_asta>0),

    FOREIGN KEY(prodotto) REFERENCES Prodotto(seriale),
    FOREIGN KEY(banditore) REFERENCES Banditore(p_iva),
    FOREIGN KEY(offerta_vincente) REFERENCES Offerta(orario_offerta),
    FOREIGN KEY(sponsor) REFERENCES Sponsor(p_iva)
);

CREATE TABLE Offerta(
    asta CHAR(12),
    offerente CHAR(16),
    orario_offerta DATETIME NOT NULL,
    import INT NOT NULL,

    CHECK (codice ~ '^[0-9]{12}'),
    FOREIGN KEY(asta) REFERENCES Asta(id_asta),
    FOREIGN KEY(offerente) REFERENCES Persona(codice_fiscale),

    CONSTRAINT PK_Offerta PRIMARY KEY(asta, orario_offerta)
);
