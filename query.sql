--QUERY 1: Trovare gli utenti che hanno vinto più di 3 aste
SELECT p.nome, p.cognome, p.codice_fiscale, COUNT(p.codice_fiscale)
FROM Asta a INNER JOIN Offerta o ON(a.codice = o.asta AND a.dataOra_offerta_vincente = o.orario_offerta)
INNER JOIN Persona p ON(o.offerente = p.codice_fiscale)
WHERE a.data_fine IS NOT NULL
GROUP BY o.offerente
HAVING COUNT(o.offerente) > 3;

--QUERY 2: Per ogni tipo di competenza, trovare quali sono i banditori specializzati
--in essa nell'ultimo anno
SELECT b.partita_iva AS p_iva_banditore, b.nome, b.sede, b.esperienza, c.data_specializzazione
FROM Competenza c INNER JOIN Banditore b ON(c.banditore = b.partita_iva)
WHERE c.data_specializzazione >= CURRENT_DATE - INTERVAL '1 year';

--QUERY 3: Trovare per ogni sponsor il valore medio (di vendita) dei prodotti venduti nelle 
--aste da lui sponsorizzate
SELECT s.p_iva, s.nome, AVG(a.importo) AS media_prezzo_vendita
FROM Asta a INNER JOIN Sponsor s ON(a.sponsor = s.p_iva) 
INNER JOIN Offerta o ON(a.codice = o.asta AND a.dataOra_offerta_vincente = o.orario_offerta)
WHERE a.data_fine IS NOT NULL
GROUP BY s.p_iva;

--QUERY 4: Trovare le persone in possesso di almeno un prodotto con certificato di autenticità 
--raggruppandoli per proprietario in modo da vedere più facilmente per ogni persona quali sono i sui prodotti certificati
SELECT p.codice_fiscale, p.nome, p.cognome, COUNT(pos.prodotto) AS num_prodotti_certificati
FROM Persona p INNER JOIN Possesso pos ON(p.codice_fiscale = pos.proprietario) INNER JOIN Autenticazione a ON(a.prodotto = pos.prodotto)
WHERE pos.data_fine IS NULL
GROUP BY p.codice_fiscale;


--QUERY 5: Trovare le aste in cui l'offerta finale ha superato del 100% la base d'asta
SELECT a.codice, a.prodotto, a.base_asta, a.data_inizio, a.data_fine, a.dataOra_offerta_vincente, a.banditore, a.num_partecipanti
FROM Asta a INNER JOIN Offerta o ON(a.codice = o.asta AND a.dataOra_offerta_vincente = o.orario_offerta)
WHERE a.data_fine IS NOT NULL AND o.importo = a.base_asta*2;