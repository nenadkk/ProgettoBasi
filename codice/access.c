#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

void endConnection(PGconn* connection) {
    PQfinish(connection);
    exit(1);
}

int main() { 
    PGconn* connection = PQconnectdb("dbname=progettobasi user=progetto");

    if(PQstatus(connection) == CONNECTION_BAD) {
        fprintf(stderr, "Connessione al database fallita : %s", PQerrorMessage(connection));
        endConnection(connection);
    }
    
    else {
        printf("Database perfettamente collegato!\n");
    }
    PQfinish(connection);
    return 0;
}
