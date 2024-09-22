# Database Oncogeni
Un progetto in MySQL in cui abbiamo unito i dati da diversi database disponibili (SIGNOR, CancerGeneNet, Uniprot) online per creare un unico database che contenesse tutti i dati disponibili e facilmente accessibili.
Lo schema concettuale del database è visibile in Diagramma progetto.jpg

Sono riportate le tabelle che costituiscono il database in formato .csv per poter scaricare e utilizzare subito il database. All'intero del file Codice_Database.sql sono presenti delle query di esempio.

Sono inoltre riportati il codice ed i dataset utilizzati per creare il database. Il procedimento è riportato sotto.

# Workflow
I dati dai tre diversi database utilizzati si possono scaricare tramite il file download_data.ipybn. Le tabelle sono comunque già disponibili nella cartella Dataset, ad eccezione della tabella contenente i dati di Uniprot in quanto troppo grande per essere salvata in GitHub.

I dati vengono scaricati in formato .csv e possono essere visionati tramite load_data.ipybn. 

Il database si può creare in MySQL Workbench prima importando le tabelle scaricate e poi eseguire il file Codice_Database.sql

Inoltre il file Codice_Database.sql contiene delle query di esempio da utilizzare sul database. 


# Caveat
  Il progetto del database implica una relazione di tipo uno-a-uno tra i geni e le proteine, ovvero un gene codifica per una e una sola proteina. Ciò non è necessariamente vero e perciò il database andrebbe corretto in tal senso.


# Autori del progetto

  Iacuone Diego
  
  Odierno Aurora
  
  Pachiarotti Giulio


# Bibliografia

SIGNOR:  Lo Surdo P, Iannuccelli M, Contino S, Castagnoli L, Licata L, Cesareni G, Perfetto L. SIGNOR 3.0, the SIGnaling network open resource 3.0: 2022 update. Nucleic Acids Res. 2022 Oct 16:gkac883. doi: 10.1093/nar/gkac883. Epub ahead of print. PMID: 36243968.


Cancer Gene Net:  Dressler, Lisa, et al. "Comparative assessment of genes driving cancer and somatic evolution in non-cancer tissues: an update of the Network of Cancer Genes (NCG) resource." Genome biology 23.1 (2022): 35.


The UniProt Consortium , UniProt: the Universal Protein Knowledgebase in 2023, Nucleic Acids Research, Volume 51, Issue D1, 6 January 2023, Pages D523–D531, https://doi.org/10.1093/nar/gkac1052 
