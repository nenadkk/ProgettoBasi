#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

#define CHARACTERS_PER_COLUMN 30
#define QUERIES 5

// Descrizioni delle query
const char* queryDescriptions[QUERIES] = {
    "Elenca utenti che hanno vinto almeno un certo numero di aste.",
    "Mostra banditori con competenze ottenute da data specifica (YYYY-MM-DD).",
    "Calcola media prezzi di vendita per sponsor con minimo aste vinte.",
    "Conta prodotti autenticati in possesso attivo da data specifica (YYYY-MM-DD).",
    "Visualizza aste con offerta vincente superiore a multiplo base asta e minimo offerte."
};

// Query SQL parametriche
const char* queries[QUERIES] = {
    // 1
    "SELECT p.nome, p.cognome, p.codice_fiscale, COUNT(*) AS aste_vinte "
    "FROM Asta a "
    "JOIN Offerta o ON a.codice_asta = o.asta "
    "JOIN Persona p ON o.offerente = p.codice_fiscale "
    "WHERE a.data_fine IS NOT NULL AND o.importo = a.importo_offerta_vincente "
    "GROUP BY p.nome, p.cognome, p.codice_fiscale "
    "HAVING COUNT(*) >= $1 "
    "ORDER BY aste_vinte DESC;",

    // 2
    "SELECT b.partita_iva AS p_iva_banditore, c.data_specializzazione, s.nome AS nome_specializzazione, s.livello "
    "FROM Competenza c "
    "INNER JOIN Banditore b ON c.banditore = b.partita_iva "
    "INNER JOIN Specializzazione s ON c.codice_specializzazione = s.codice_specializzante "
    "    AND c.certificatore = s.certificatore "
    "WHERE c.data_specializzazione >= $1 "
    "ORDER BY b.partita_iva, c.data_specializzazione;",

    // 3
    "SELECT s.partita_iva, s.nome, AVG(a.importo_offerta_vincente) AS media_prezzo_vendita "
    "FROM Asta a "
    "INNER JOIN Sponsor s ON a.sponsor = s.partita_iva "
    "INNER JOIN Offerta o ON a.codice_asta = o.asta AND a.importo_offerta_vincente = o.importo "
    "WHERE a.data_fine IS NOT NULL "
    "GROUP BY s.partita_iva, s.nome "
    "HAVING COUNT(*) >= $1 "
    "ORDER BY s.nome ASC;",

    // 4
    "SELECT p.codice_fiscale, p.nome, p.cognome, COUNT(pos.prodotto) AS num_prodotti_certificati "
    "FROM Persona p "
    "INNER JOIN Possesso pos ON p.codice_fiscale = pos.proprietario "
    "INNER JOIN Autenticazione a ON a.prodotto = pos.prodotto "
    "WHERE pos.data_fine IS NULL OR pos.data_fine > $1 "
    "GROUP BY p.codice_fiscale "
    "ORDER BY num_prodotti_certificati DESC;",

    // 5
    "SELECT a.codice_asta, a.prodotto, a.base_asta, a.importo_offerta_vincente, a.num_partecipanti "
    "FROM Asta a "
    "JOIN Offerta o ON a.codice_asta = o.asta "
    "WHERE a.data_fine IS NOT NULL AND a.importo_offerta_vincente >= a.base_asta * $1 "
    "GROUP BY a.codice_asta, a.prodotto, a.base_asta, a.importo_offerta_vincente, a.num_partecipanti "
    "HAVING COUNT(o.orario_offerta) >= $2 "
    "ORDER BY a.codice_asta ASC;"
};

void errorDuringConnection(PGconn* dbConn, const char* message) {
    fprintf(stderr, "%s: %s\n", message, PQerrorMessage(dbConn));
    PQfinish(dbConn);
    exit(EXIT_FAILURE);
}

PGconn* startDataBaseConnection() {
    PGconn* dbConnection = PQconnectdb("dbname=progettobasi user=progetto");

    if (PQstatus(dbConnection) != CONNECTION_OK) {
        errorDuringConnection(dbConnection, "Errore durante il collegamento al database");
    }

    printf("Connessione al database avvenuta correttamente!\n");

    return dbConnection;
}

void endDataBaseConnection(PGconn* dbConn) {
    if (dbConn) {
        PQfinish(dbConn);
        printf("Connessione al database terminata!\n");
    }
}

void printQueryResults(PGresult* result) {
    int columns = PQnfields(result);
    int rows = PQntuples(result);

    printf("\nRisultati query:\n");
    // Stampa intestazioni
    for (int i = 0; i < columns; i++) {
        printf("| %-*s ", CHARACTERS_PER_COLUMN, PQfname(result, i));
    }
    printf("|\n");

    // Linea di separazione
    for (int i = 0; i < columns; i++) {
        printf("|-%.*s-", CHARACTERS_PER_COLUMN, "------------------------------");
    }
    printf("|\n");

    // Stampa righe
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            const char* value = PQgetvalue(result, i, j);
            printf("| %-*s ", CHARACTERS_PER_COLUMN, value);
        }
        printf("|\n");
    }
    printf("\n");
}

void executeParameterizedQuery(PGconn* dbConn, const char* query, int nParams, const char* paramValues[]) {
    PGresult* queryResult = PQexecParams(dbConn, query, nParams, NULL, paramValues, NULL, NULL, 0);

    if (PQresultStatus(queryResult) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore nell'esecuzione della query parametrica: %s\n", PQerrorMessage(dbConn));
        PQclear(queryResult);
        return;
    }

    printQueryResults(queryResult);
    PQclear(queryResult);
}

void executeQuery(PGconn* dbConn, const char* query) {
    PGresult* queryResult = PQexec(dbConn, query);

    if (PQresultStatus(queryResult) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore nell'esecuzione della query: %s\n", PQerrorMessage(dbConn));
        PQclear(queryResult);
        return;
    }

    printQueryResults(queryResult);
    PQclear(queryResult);
}

void clearInputBuffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF) { }
}

int askInt(const char* prompt) {
    int val;
    while (1) {
        printf("%s", prompt);
        if (scanf("%d", &val) != 1) {
            printf("Input non valido, riprova.\n");
            clearInputBuffer();
            continue;
        }
        clearInputBuffer();
        return val;
    }
}

void askString(const char* prompt, char* buffer, int size) {
    printf("%s", prompt);
    if (fgets(buffer, size, stdin) == NULL) {
        buffer[0] = '\0';
        return;
    }
    buffer[strcspn(buffer, "\n")] = '\0'; // rimuove newline
}

void querySelector(PGconn* dbConn) {
    int input = -1;

    while (input != 0) {
        printf("\n=== MENU QUERY ===\n");
        printf("0) Esci\n");
        for (int i = 0; i < QUERIES; ++i) {
            printf("%d) %s\n", i + 1, queryDescriptions[i]);
        }

        input = askInt("Seleziona una query da eseguire (0 per uscire): ");

        if (input == 0) {
            printf("Uscita dal programma.\n");
            break;
        }

        if (input < 1 || input > QUERIES) {
            printf("Scelta non valida. Inserisci un numero da 0 a %d.\n", QUERIES);
            continue;
        }

        printf("Esecuzione query: %s\n", queryDescriptions[input - 1]);

        switch (input) {
            case 1: {
                // Param: numero minimo aste vinte (intero)
                int min_aste = askInt("Inserisci il numero minimo di aste vinte: ");
                char param_str[12];
                snprintf(param_str, sizeof(param_str), "%d", min_aste);
                const char* params[1] = { param_str };
                executeParameterizedQuery(dbConn, queries[0], 1, params);
                break;
            }

            case 2: {
                // Param: data in formato YYYY-MM-DD
                char data[20];
                askString("Inserisci la data minima di specializzazione (YYYY-MM-DD): ", data, sizeof(data));
                const char* params[1] = { data };
                executeParameterizedQuery(dbConn, queries[1], 1, params);
                break;
            }

            case 3: {
                // Param: minimo numero aste vinte (intero)
                int min_aste = askInt("Inserisci il numero minimo di aste vinte per sponsor: ");
                char param_str[12];
                snprintf(param_str, sizeof(param_str), "%d", min_aste);
                const char* params[1] = { param_str };
                executeParameterizedQuery(dbConn, queries[2], 1, params);
                break;
            }

            case 4: {
                // Param: data in formato YYYY-MM-DD per filtro possesso attivo
                char data[20];
                askString("Inserisci la data per filtro possesso attivo (YYYY-MM-DD): ", data, sizeof(data));
                const char* params[1] = { data };
                executeParameterizedQuery(dbConn, queries[3], 1, params);
                break;
            }

            case 5: {
                // Param: multiplo base asta (float accettato come stringa)
                //       numero minimo offerte (int)
                char multiplo_str[20];
                int min_offerte;

                askString("Inserisci il multiplo della base asta: ", multiplo_str, sizeof(multiplo_str));
                min_offerte = askInt("Inserisci il numero minimo di offerte: ");

                const char* params[2] = { multiplo_str, NULL };
                char min_offerte_str[12];
                snprintf(min_offerte_str, sizeof(min_offerte_str), "%d", min_offerte);
                params[1] = min_offerte_str;

                executeParameterizedQuery(dbConn, queries[4], 2, params);
                break;
            }

            default:
                printf("Query non gestita.\n");
                break;
        }
    }
}

int main() {
    PGconn* dbConnection = startDataBaseConnection();

    querySelector(dbConnection);

    endDataBaseConnection(dbConnection);

    return 0;
}
