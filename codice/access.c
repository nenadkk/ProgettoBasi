#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

#define CHARACTERS_PER_COLUMN 30
#define QUERIES 5

const char* queryDescriptions[QUERIES] = {
    "Trovare gli utenti che hanno vinto almeno N aste e riportarne il nome, il cognome, il codice fiscale e il numero di aste vinte",
    "Mostrare i banditori con competenze acquisite negli ultimi N anni",
    "Media dei prezzi di vendita per sponsor con almeno N aste vinte",
    "Contare i prodotti autenticati in possesso attuale delle persone",
    "Visualizzare aste con offerta vincente superiore alla base d'asta * 10 e almeno 5 offerte"
};

const char* queries[QUERIES] = {
    //Query 1
    "SELECT p.nome, p.cognome, p.codice_fiscale, COUNT(*) AS aste_vinte "
    "FROM Asta a JOIN Offerta o ON a.codice_asta = o.asta JOIN Persona p ON o.offerente = p.codice_fiscale "
    "WHERE a.data_fine IS NOT NULL AND o.importo = a.importo_offerta_vincente "
    "GROUP BY p.nome, p.cognome, p.codice_fiscale "
    "HAVING COUNT(*) >= 1;",
    
    // Query 2 (parametrica - N anni)
    "SELECT b.partita_iva AS p_iva_banditore, b.nome, b.sede, b.esperienza, c.data_specializzazione "
    "FROM Competenza c INNER JOIN Banditore b ON(c.banditore = b.partita_iva) "
    "WHERE c.data_specializzazione >= CURRENT_DATE - INTERVAL '$1 year';",

    // Query 3 (parametrica - N aste vinte)
    "SELECT s.partita_iva, s.nome, AVG(a.importo_offerta_vincente) AS media_prezzo_vendita "
    "FROM Asta a INNER JOIN Sponsor s ON(a.sponsor = s.partita_iva) INNER JOIN Offerta o ON(a.codice_asta = o.asta AND a.importo_offerta_vincente = o.importo) "
    "WHERE a.data_fine IS NOT NULL "
    "GROUP BY s.partita_iva, s.nome "
    "HAVING COUNT(*) >= $1 "
    "ORDER BY s.nome ASC;",

    //Query 4
    "SELECT p.codice_fiscale, p.nome, p.cognome, COUNT(pos.prodotto) AS num_prodotti_certificati "
    "FROM Persona p INNER JOIN Possesso pos ON(p.codice_fiscale = pos.proprietario) INNER JOIN Autenticazione a ON(a.prodotto = pos.prodotto) "
    "WHERE pos.data_fine IS NULL "
    "GROUP BY p.codice_fiscale;",

    //Query 5
    "SELECT a.codice_asta, a.prodotto, a.base_asta, a.importo_offerta_vincente, a.num_partecipanti "
    "FROM Asta a JOIN Offerta o ON a.codice_asta = o.asta "
    "WHERE a.data_fine IS NOT NULL AND a.importo_offerta_vincente >= a.base_asta * 10 "
    "GROUP BY a.codice_asta, a.prodotto, a.base_asta, a.data_inizio, a.data_fine, a.importo_offerta_vincente, a.banditore, a.num_partecipanti "
    "HAVING COUNT(o.orario_offerta) >= 5 "
    "ORDER BY a.codice_asta ASC;"

};

void errorDuringConnection(PGconn* dbConn, const char* message) {
    fprintf(stderr, "%s %s\n", message, PQerrorMessage(dbConn));
    PQfinish(dbConn);
    exit(EXIT_FAILURE);
}

PGconn* startDataBaseConnection() {
    PGconn* dbConnection = PQconnectdb("dbname=progettobasi user=progetto");

    if(PQstatus(dbConnection) != CONNECTION_OK) {
        errorDuringConnection(dbConnection, "Errore durante il collegamento al database");
    }

    printf("Connessione al database avvenuta correttamente!\n");
    
    return dbConnection;
}

void endDataBaseConnection(PGconn* dbConn) {
    if(dbConn) {
        PQfinish(dbConn);
        printf("Connessione al database terminata!\n");
    }
}

void printQueryResults(PGresult* result) {
    int columns = PQnfields(result);
    int rows = PQntuples(result);

    printf("Stampa dei risultati della query\n ---------\n");
    // Intestazioni
    for (int i = 0; i < columns; i++) {
        printf("| %-*s", CHARACTERS_PER_COLUMN, PQfname(result, i));
    }
    printf("|\n");

    // Linea separatrice
    for (int i = 0; i < columns; i++) {
        printf("|%.*s", CHARACTERS_PER_COLUMN + 1, "-----------------------------------");
    }
    printf("|\n");

    // Righe
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            const char *value = PQgetvalue(result, i, j);
            printf("| %-*s", CHARACTERS_PER_COLUMN, value);
        }
        printf("|\n");
    }
}

void executeQuery(PGconn* dbConn, const char* query) {
    PGresult* queryResult = PQexec(dbConn, query);

    if(PQresultStatus(queryResult) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore nella esecuzione della query : %s", PQerrorMessage(dbConn));
        PQclear(queryResult);
        return;
    }

    //stampa dei risultati della query
    printQueryResults(queryResult);
    PQclear(queryResult);
}

void executeParameterizedQuery(PGconn* dbConn, const char* query, int numParams, const char** paramValues) {
    PGresult* result = PQexecParams(dbConn, query, numParams, NULL, paramValues, NULL, NULL, 0);

    if (PQresultStatus(result) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore nella esecuzione della query parametrica: %s", PQerrorMessage(dbConn));
        PQclear(result);
        return;
    }

    printQueryResults(result);
    PQclear(result);
}

void querySelector(PGconn* dbConn) {
    int input = -1;

    while (input != 0) {
        printf("\n=== MENU QUERY ===\n");
        printf("0) Esci\n");
        for (int i = 0; i < QUERIES; ++i) {
            printf("Query %d) %s\n", i + 1, queryDescriptions[i]);
        }

        printf("Si scelga una query da eseguire (0 per uscire): ");
        if (scanf("%d", &input) != 1) {
            // Input non numerico
            while (getchar() != '\n'); // Pulisci buffer
            printf("Input non valido. Si inserica un numero valido.\n");
            input = -1;
            continue;
        }

        if (input == 0) {
            printf("Uscita dal programma.\n");
        }

        else if (input >= 1 && input <= QUERIES) {
            printf("Esecuzione query: %s\n", queryDescriptions[input - 1]);
        
            if (input == 2) {
                // Parametro: numero di anni
                int anni;
                printf("Inserisci il numero di anni (es. 1 per ultimo anno): ");
                scanf("%d", &anni);
                char anni_str[10];
                snprintf(anni_str, sizeof(anni_str), "%d", anni);
                const char* paramValues[1] = { anni_str };
                executeParameterizedQuery(dbConn, queries[1], 1, paramValues);
            }
        
            else if (input == 3) {
                // Parametro: numero minimo di aste vinte
                int minimo;
                printf("Inserisci il numero minimo di aste vinte: ");
                scanf("%d", &minimo);
                char minimo_str[10];
                snprintf(minimo_str, sizeof(minimo_str), "%d", minimo);
                const char* paramValues[1] = { minimo_str };
                executeParameterizedQuery(dbConn, queries[2], 1, paramValues);
            }
        
            else {
                executeQuery(dbConn, queries[input - 1]);
            }
        }
        
        else {
            printf("Scelta non valida. Inserisci un numero da 0 a %d.\n", QUERIES);
        }
    }
}
int main() {
    //connessione al database
    PGconn* dbConnection = startDataBaseConnection();

    querySelector(dbConnection);

    endDataBaseConnection(dbConnection);
    return 0;
}