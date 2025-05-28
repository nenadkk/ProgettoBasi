--QUERY 1: Trovare gli utenti che hanno vinto più di 3 aste
SELECT p.nome, p.cognome, p.codice_fiscale, COUNT(*) AS aste_vinte
FROM Asta a JOIN Offerta o ON a.codice_asta = o.asta JOIN Persona p ON o.offerente = p.codice_fiscale
WHERE a.data_fine IS NOT NULL AND o.importo = a.importo_offerta_vincente
GROUP BY p.nome, p.cognome, p.codice_fiscale
HAVING COUNT(*) > 3;

--QUERY 2: Per ogni tipo di competenza, trovare quali sono i banditori specializzati
--in essa nell'ultimo anno
SELECT b.partita_iva AS p_iva_banditore, b.nome, b.sede, b.esperienza, c.data_specializzazione, s.nome AS nome_specializzazione
FROM Competenza c INNER JOIN Banditore b ON c.banditore = b.partita_iva INNER JOIN Specializzazione s ON c.codice_specializzazione = s.codice_specializzante AND c.certificatore = s.certificatore
WHERE c.data_specializzazione >= CURRENT_DATE - INTERVAL '1 year';

--QUERY 3: Trovare per ogni sponsor il valore medio (di vendita) dei prodotti venduti nelle 
--aste da lui sponsorizzate
SELECT s.partita_iva, s.nome, AVG(o.importo) AS media_prezzo_vendita
FROM Asta a INNER JOIN Sponsor s ON(a.sponsor = s.partita_iva) 
INNER JOIN Offerta o ON(a.codice_asta = o.asta AND a.importo_offerta_vincente = o.importo)
WHERE a.data_fine IS NOT NULL
GROUP BY s.partita_iva, s.nome;

--QUERY 4: Trovare le persone in possesso di almeno un prodotto con certificato di autenticità 
--raggruppandoli per proprietario in modo da vedere più facilmente per ogni persona quali sono i sui prodotti certificati
SELECT p.codice_fiscale, p.nome, p.cognome, COUNT(pos.prodotto) AS num_prodotti_certificati
FROM Persona p INNER JOIN Possesso pos ON(p.codice_fiscale = pos.proprietario) INNER JOIN Autenticazione a ON(a.prodotto = pos.prodotto)
WHERE pos.data_fine IS NULL
GROUP BY p.codice_fiscale;

--QUERY 5: Trovare le aste in cui l'offerta finale ha superato del 100% la base d'asta
SELECT a.codice_asta, a.prodotto, a.base_asta,  a.importo_offerta_vincente 
FROM Asta a JOIN Offerta o ON a.codice_asta = o.asta
WHERE a.data_fine IS NOT NULL AND a.importo_offerta_vincente >= a.base_asta * 1.5
GROUP BY a.codice_asta, a.prodotto, a.base_asta, a.importo_offerta_vincente
HAVING COUNT(o.orario_offerta) >= 5;