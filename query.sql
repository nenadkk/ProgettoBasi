CREATE TABLE Persona(
    codice_fiscale CHAR(16) PRIMARY KEY,
    nome VARCHAR NOT NULL,
    cognome VARCHAR NOT NULL
)

CREATE TABLE Certificatore(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR NOT NULL,
    sede VARCHAR NOT NULL,
    anno_fondazione YEAR NOT NULL,
    collaboratori SMALLINT NOT NULL,
    tipologia VARCHAR NOT NULL,

    CHECK (anno_fondazione>1000),
    CHECK (collaboratori>0),
    CHECK (partita_iva ~ '^[0-9]{11}$')
)

CREATE TABLE Banditore(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR NOT NULL,
    sede VARCHAR NOT NULL,
    anno_fondazione YEAR NOT NULL,
    collaboratori SMALLINT NOT NULL,
    esperienza SMALLINT NOT NULL,

    CHECK (anno_fondazione>1000),
    CHECK (collaboratori>0),
    CHECK (partita_iva ~ '^[0-9]{11}$')
)

CREATE TABLE Sponsor(
    partita_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR NOT NULL,
    sede VARCHAR NOT NULL,
    anno_fondazione YEAR NOT NULL,
    collaboratori SMALLINT NOT NULL,
    tipologia VARCHAR NOT NULL,
    livello VARCHAR NOT NULL,

    CHECK (anno_fondazione>1000),
    CHECK (collaboratori>0),
    CHECK (partita_iva ~ '^[0-9]{11}$')
)

CREATE TABLE Prodotto(
    codice CHAR(12) PRIMARY KEY,
    nome VARCHAR NOT NULL,
    valutazione INT NOT NULL,
    tipologia VARCHAR NOT NULL,
    proprietario CHAR(16),

    CHECK (valutazione>0), --un prodotto non può avere valutazione negativa
    CHECK (codice ~ '^[0-9]{16}$'),

    FOREIGN KEY(proprietario) REFERENCES Persona(codice_fiscale)
)

CREATE TABLE Certificato(
    codice CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR NOT NULL,
    prodotto CHAR(12),
    data_emanazione DATE NOT NULL,
    tecnica_analisi VARCHAR NOT NULL,

    CHECK (codice ~ '^[0-9]{16}$'),
    FOREIGN KEY(certificatore) REFERENCES Certificatore(partita_iva),
    FOREIGN KEY(prodotto) REFERENCES Prodotto(codice),
    CONSTRAINT PK_Certificato PRIMARY KEY(codice,certificatore)
)

CREATE TABLE Specializzazione(
    codice CHAR(12) NOT NULL,
    certificatore CHAR(11),
    nome VARCHAR NOT NULL,
    banditore CHAR(16),
    data_emanazione DATE NOT NULL,
    livello VARCHAR NOT NULL,
    
    CHECK (codice ~ '^[0-9]{16}$'),
    FOREIGN KEY(certificatore) REFERENCES Certificatore(partita_iva),
    FOREIGN KEY(banditore) REFERENCES Banditore(partita_iva),

    CONSTRAINT PK_Specializzazione PRIMARY KEY(codice,certificatore)
)

CREATE TABLE Asta(
    id_asta CHAR(12) PRIMARY KEY,
    prodotto CHAR(12),
    banditore CHAR(16),
    data_inizio DATE NOT NULL,
    data_fine DATE DEFAULT NULL,
    base_asta INT NOT NULL,
    offerta_max INT DEFAULT 0,
    num_partecipanti INT DEFAULT 0,
    sponsor CHAR(16),

    CHECK (id_asta ~ '^[0-9]{12}$'),
    FOREIGN KEY(prodotto) REFERENCES Prodotto(codice),
    FOREIGN KEY(banditore) REFERENCES Banditore(partita_iva),
    FOREIGN KEY(sponsor) REFERENCES Sponsor(partita_iva)
)

CREATE TABLE Offerta(
    codice CHAR(12) PRIMARY KEY,
    asta CHAR(16),
    offerente CHAR(16),
    orario_offerta DATE NOT NULL,
    import INT NOT NULL,

    CHECK (codice ~ '^[0-9]{12}'),
    FOREIGN KEY(asta) REFERENCES Asta(id_asta),
    FOREIGN KEY(offerente) REFERENCES Persona(codice_fiscale)
)










