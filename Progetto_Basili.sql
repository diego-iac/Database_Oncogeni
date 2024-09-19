CREATE DATABASE IF NOT EXISTS DB_Basili;
USE DB_Basili;

-- Tabelle da caricare tramite Import Wizard:
-- uniprot_info_2
-- prosite_info
-- signor_info_corretto
-- prosite_protein_info_total

CREATE TABLE proteina AS
SELECT Entry,`Entry Name`,`Gene Names (primary)`,`Protein names`,Sequence,`Subcellular location [CC]`
FROM DB_Basili.uniprot_info_2;

Create Table prot_uniq_name as
Select distinct * from proteina;


/*
################################################################ check per valore nullo
SELECT *
FROM prot_uniq_name
WHERE Entry IS NULL OR Entry Name IS NULL OR Gene Name (primary) IS NULL OR Protein names IS NULL;
*/

/*
################################################################ questo codice trova i valori duplicati per una colonna di una tabella
SELECT *
FROM DB_Basili.prot_uniq_name
WHERE `Gene Names (primary)` IN (
    SELECT `Gene Names (primary)`
    FROM DB_Basili.prot_uniq_name
    GROUP BY `Gene Names (primary)`
    HAVING COUNT(*) > 1
);
*/

DELETE FROM DB_Basili.prot_uniq_name
WHERE Entry NOT IN (
    SELECT Entry
    FROM (
        SELECT MIN(Entry) AS Entry
        FROM DB_Basili.prot_uniq_name
        GROUP BY `Gene Names (primary)`
    ) AS temp
); #questo iter rimuove tutti i duplicati, tenendone un valore solo, per una colonna di una tabella, usando il valore della colonna nella WHERE .. NOT IN per decidere tramite quel valore quale dei duplicati mantenere

# Da qui in avanti i duplicati devono essere stati unicizzati o rimossi

ALTER TABLE DB_Basili.prot_uniq_name 
MODIFY COLUMN Entry VARCHAR(20) NOT NULL; 

ALTER TABLE DB_Basili.prot_uniq_name 
ADD PRIMARY KEY (Entry);
#rendo una primary key l'attributo gene name primary


###################################################### Tabella SIG (SIGNOR)

CREATE TABLE signor AS
SELECT `Path String`, `Final Effect`, `Protein`, Hallmark
FROM signor_info_corretto;

CREATE TABLE sig AS
SELECT s.*, p.Entry
FROM signor s
JOIN prot_uniq_name p ON s.protein = p.`Gene Names (primary)`;

ALTER TABLE sig
ADD FOREIGN KEY (Entry) REFERENCES prot_uniq_name(Entry);  # aggiunta foreing key

ALTER TABLE sig 
ADD COLUMN S_ID INT AUTO_INCREMENT PRIMARY KEY;

DROP TABLE DB_Basili.proteina; #rimuovo le tabelle temporanee che non servono più
DROP TABLE DB_Basili.signor;

################### fine codice Diego per creazione tabelle



################### query di esempio DB Diego

# ottenere tutti i percorsi associati a una specifica proteina:
SELECT DISTINCT s.`Path String`
FROM sig s
JOIN prot_uniq_name p ON s.protein = p.`Gene Names (primary)`
WHERE p.Entry = 'P00519'; -- Sostituisci con l'Entry della proteina desiderata

# ottenere tutti i dati da n proteine associate a un percorso specifico nel database SIGNOR:
SELECT  DISTINCT s.protein, p.Entry names
FROM sig s
JOIN prot_uniq_name p ON s.protein = p.`Gene Names (primary)`
WHERE s.`Hallmark` = 'ANGIOGENESIS' AND s.protein = 'ABL1';



#########################################################    DATABASE:	DRIVERS      ###########################################################################



# Per prima cosa va scaricata con import wizard la tabella drivers contenente tutti i dati

ALTER TABLE `DB_Basili`.`drivers` 
RENAME TO  `DB_Basili`.`drivers_original` ;

### Inizio creazione tabelle

ALTER TABLE drivers_original 
ADD COLUMN drivers_id INT AUTO_INCREMENT PRIMARY KEY;

CREATE TABLE drivers_init AS
SELECT entrez,symbol,pubmed_id,organ_system,driver_type,drivers_id
FROM DB_Basili.drivers_original;

CREATE TABLE drivers as 
SELECT s.*, p.Entry
FROM drivers_init s
JOIN prot_uniq_name p ON s.symbol = p.`Gene Names (primary)`;

ALTER TABLE drivers 
ADD PRIMARY KEY (drivers_id);

ALTER TABLE drivers
ADD FOREIGN KEY (Entry) REFERENCES prot_uniq_name(Entry);

Drop table drivers_init;

CREATE TABLE cancer_drivers
(
	drivers_id INT PRIMARY KEY,
    driver_type VARCHAR(20),
    primary_site VARCHAR(40),
    cancer_type VARCHAR(100),
    method VARCHAR(200)
);

INSERT INTO cancer_drivers(drivers_id, driver_type, primary_site,cancer_type,method)
SELECT drivers_id, driver_type, primary_site, cancer_type, method
FROM drivers_original
WHERE drivers_original.driver_type = "cancer";

CREATE TABLE healthy_drivers
(
	drivers_id INT PRIMARY KEY,
    driver_type VARCHAR(20)
);

INSERT INTO healthy_drivers(drivers_id,driver_type)
SELECT drivers_id, driver_type
FROM drivers
WHERE drivers.driver_type = "healthy";

##############################################################       QUERY 
########################################################	restituisce il nome e la conta dei pathway del gene (o dei geni) che attiva il maggiore numero di pathway

SELECT d.symbol, COUNT(s.`Path String`) AS num_pathways 
FROM drivers d 
JOIN sig s ON d.symbol = s.protein
GROUP BY d.symbol 
HAVING COUNT(s.`Path String`) IN (
    SELECT MAX(num_pathways)
    FROM (
        SELECT COUNT(`Path String`) AS num_pathways
        FROM sig
        GROUP BY protein
    ) AS pathway_counts
);

########################################################	query prende i pathway che attiva un determinato gene fornito nel WHERE
SELECT DISTINCT s.`Path String`
FROM sig s
JOIN (
    SELECT d.symbol, c.cancer_type, d.Entry
    FROM drivers d
    JOIN cancer_drivers c ON d.drivers_id = c.drivers_id
    WHERE d.symbol='ABL1'
) AS temp ON s.Entry = temp.Entry;

####################################################### DATABASE:  MOTIVI POSIZIONE ##############################################################
# creazione e popolamento tabelle
  # carico la tabella prosite_protein_info_total  aggiungo una colonna con autoincrement che fa da chiave delle posizioni 

ALTER TABLE prosite_protein_info_total
ADD COLUMN pos_id INT AUTO_INCREMENT PRIMARY KEY;

# posizioni
CREATE TABLE posizioni(
	id_posizione INT AUTO_INCREMENT,
	start INT,
    stop INT,
    PRIMARY KEY(id_posizione));

INSERT INTO posizioni(start, stop, id_posizione)
SELECT start, stop, pos_id
FROM prosite_protein_info_total;


# motivi
CREATE TABLE motivi(
	AC_m VARCHAR(10),
	nome VARCHAR(100),
    descrizione VARCHAR(100),
    pattern VARCHAR(400),
    PRIMARY KEY(AC_m)
    );

INSERT INTO motivi(AC_m, nome, descrizione, pattern)
SELECT accession, name, description, pattern
FROM prosite_info;

CREATE TABLE motivi_proteine_initial(
	AC_m VARCHAR(50),
    id_pos INT,
    AC_p VARCHAR(50),
    PRIMARY KEY(AC_p, AC_m, id_pos)
    );
    

INSERT INTO motivi_proteine_initial(AC_m, id_pos, AC_p)
SELECT signature_ac, pos_id, uniprot_ac
FROM prosite_protein_info_total;  
    
CREATE TABLE motivi_proteine as 
SELECT mp.*
FROM   motivi m, prot_uniq_name p, motivi_proteine_initial mp
WHERE m.AC_m = mp.AC_m AND p.Entry = mp.AC_p;
    
ALTER TABLE motivi_proteine
ADD constraint proteine_constrain
FOREIGN KEY (AC_p) REFERENCES prot_uniq_name(Entry);

ALTER TABLE motivi_proteine
ADD constraint posizioni_constrain
FOREIGN KEY (id_pos) REFERENCES posizioni(id_posizione);

ALTER TABLE motivi_proteine
ADD constraint motivi_constrain
FOREIGN KEY (AC_m) REFERENCES motivi(AC_m);


####################################################################   QUERY 

######################################## ricerca per ogni motivo il numero di fenotipi che attiva (positivi o negativi) 
select m.nome , count(*) as conteggio
from motivi m
JOIN motivi_proteine mp ON mp.AC_m=m.AC_m 
JOIN sig s ON s.Entry= mp.AC_p
WHERE s.`Final Effect`=1
group by m.nome
;


#########################################    Seleziona i nomi delle proteine che hanno un motivo con effetto positivo o negativo, NON entrambi, e riporta l'effetto
select DISTINCT m2.nome, s.`Final Effect`
from motivi m2
JOIN motivi_proteine mp ON mp.AC_m=m2.AC_m 
JOIN sig s ON s.Entry= mp.AC_p
where m2.nome in 
(select m.nome
from motivi m
JOIN motivi_proteine mp ON mp.AC_m=m.AC_m 
JOIN sig s ON s.Entry= mp.AC_p
WHERE s.`Final Effect`=1)

xor m2.nome in 

(select m.nome
from motivi m
JOIN motivi_proteine mp ON mp.AC_m=m.AC_m 
JOIN sig s ON s.Entry= mp.AC_p
WHERE s.`Final Effect`=-1
);

#########################################    Motivo funzionale più frequente nei geni driver del cancro
select m.nome, count(*) as conteggio
FROM motivi m
JOIN motivi_proteine mp ON mp.AC_m=m.AC_m 
JOIN drivers d ON d.Entry=mp.AC_p
JOIN cancer_drivers c ON d.drivers_id=c.drivers_id 
group by m.nome
having  count(*) in (
					select MAX(conta)
					from ( 	select count(*) as conta
							FROM motivi m
							JOIN motivi_proteine mp ON mp.AC_m=m.AC_m 
							JOIN drivers d ON d.Entry=mp.AC_p
							JOIN cancer_drivers c ON d.drivers_id=c.drivers_id 
							group by m.nome ) AS pippo
                            );
                            
                            
########################################	per quei motivi per cui è presente il pattern stampa il pattern del motivo e la sequenza delle proteine dove è presente il motivo


SELECT accession_proteina, sequenza_regolare_motivo, SUBSTRING( seq FROM sta FOR sta+20) AS sequenza_proteina_corrispondente
FROM (SELECT m.pattern as sequenza_regolare_motivo, m.AC_m, pg.Entry as accession_proteina, pg.Sequence as seq, pos.start as sta, pos.stop as sto
	FROM motivi m
	JOIN motivi_proteine mp ON m.AC_m = mp.AC_m
	JOIN posizioni pos ON pos.id_posizione = mp.id_pos
	JOIN prot_uniq_name pg ON mp.AC_p = pg.Entry
	WHERE m.pattern <> '') as temp
    ;
       
        
        # restituisci la posizione cellulare delle proteine cancer drivers
SELECT  distinct X.nome_gene,   SUBSTRING(
        X.location, 
        LOCATE('SUBCELLULAR LOCATION: ', X.location) + LENGTH('SUBCELLULAR LOCATION: '), 
        LOCATE('{', X.location) - LOCATE('SUBCELLULAR LOCATION: ', X.location) - LENGTH('SUBCELLULAR LOCATION: ')
    ) AS  localizzazione_intracellulare
FROM (	Select distinct pg.`Subcellular location [CC]` AS location, d.Entry AS nome_gene
		from prot_uniq_name pg
        join drivers d on pg.Entry=d.Entry
        where d.driver_type='cancer' and pg.`Subcellular location [CC]` is not null) AS X
        ;
   
        
                # restituisci la posizione cellulare delle proteine cancer drivers
SELECT  distinct X.nome_gene,   SUBSTRING(
        X.location, 
        LOCATE('SUBCELLULAR LOCATION: ', X.location) + LENGTH('SUBCELLULAR LOCATION: '), 
        LOCATE('{', X.location) - LOCATE('SUBCELLULAR LOCATION: ', X.location) - LENGTH('SUBCELLULAR LOCATION: ')
    ) AS  localizzazione_intracellulare
FROM (	Select distinct pg.`Subcellular location [CC]` AS location, d.Entry AS nome_gene
		from prot_uniq_name pg, drivers d, cancer_drivers
		where pg.`Subcellular location [CC]`<>"" and pg.Entry=d.Entry and d.drivers_id=cancer_drivers.drivers_id
        ) AS X
        ;
        
