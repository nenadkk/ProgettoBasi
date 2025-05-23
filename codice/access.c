#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

#define CHARACTERS_PER_COLUMN 25
#define QUERIES 5

const char* queryDescriptions[QUERIES] = {};

const char* queries[QUERIES] = {
    //Query 1
    //Query 2
    //Query 3
    //Query 4
    //Query 5
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
        printf("|%.*s", CHARACTERS_PER_COLUMN + 1, "-------------------------");
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
            executeQuery(dbConn, queries[input - 1]);
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
