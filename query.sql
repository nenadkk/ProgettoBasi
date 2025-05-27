--QUERY 1: Trovare gli utenti che hanno vinto più di 3 aste
SELECT p.nome, p.cognome, p.codice_fiscale, COUNT(p.codice_fiscale)
FROM Asta a LEFT JOIN Offerta o ON(a.codice = o.asta AND a.dataOra_offerta_vincente = o.orario_offerta)
LEFT JOIN Persona p ON(o.offerente = p.codice_fiscale)
WHERE a.data_fine IS NOT NULL
GROUP BY o.offerente
HAVING COUNT(o.offerente) > 3;

--QUERY 2: Per ogni tipo di competenza, trovare quali sono i banditori specializzati in essa nell'ultimo anno
SELECT b.partita_iva, b.nome, b.sede, b.esperienza, c.data_specializzazione
FROM Competenza c JOIN Banditore b ON(c.banditore = b.partita_iva)
WHERE c.data_specializzazione >= CURRENT_DATE - INTERVAL '1 year';  

--QUERY 3: Trovare gli sponsor delle aste riguardanti prodotti valutati sotto i 1000e
SELECT s.partita_iva, s.nome, s.sede, s.tipologia, s.livello
FROM Sponsor s INNER JOIN Asta a ON(s.partita_iva = a.sponsor) LEFT JOIN Prodotto p ON(a.prodotto = p.seriale)
WHERE p.valutazione >= 1000;

--QUERY 4: Trovare le persone in possesso di almeno un prodotto con certificato di autenticità
SELECT p.codice_fiscale, p.nome, p.cognome
FROM Persona p INNER JOIN Possesso pos ON(p.codice_fiscale = pos.proprietario) LEFT JOIN Autenticazione a ON(a.prodotto = pos.prodotto)
WHERE pos.data_fine IS NULL;


--QUERY 5: Trovare le aste in cui l'offerta finale ha superato del 100% la base d'asta
SELECT a.codice, a.prodotto, a.base_asta, a.data_inizio, a.data_fine, a.dataOra_offerta_vincente, a.banditore, a.num_partecipanti
FROM Asta a LEFT JOIN Offerta o ON(a.codice = o.asta AND a.dataOra_offerta_vincente = o.orario_offerta)
WHERE a.data_fine IS NOT NULL AND o.importo = a.base_asta*2;
