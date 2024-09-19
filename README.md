# Database Oncogeni
Un progetto in MySQL in cui abbiamo unito i dati da diversi database disponibili (SIGNOR, CancerGeneNet, Uniprot) online per creare un unico database che contenesse tutti i dati disponibili e facilmente accessibili.
Lo schema concettuale del database è visibile in Diagramma progetto.jpg

Sono riportate le tabelle che costituiscono il database in formato .csv per poter scaricare e utilizzare subito il database. Sono presenti delle query di esempio all'intero del file Progetto_Basili.sql

Sono inoltre riportati il codice ed i dataset utilizzati per creare il database. Il procedimento è riportato sotto.

# Workflow
I dati dai tre diversi database utilizzati si possono scaricare tramite il file download_data.ipybn. 

I dati sono scaricati in formato csv e possono essere visionati tramite load_data.ipybn. 

Il database si può creare in MySQL Workbench importando le tabelle scaricate e per poi eseguire il file Progetto_Basili.sql

Il file Progetto_Basili.sql contiene delle query di esempio per mostrare l'uso del database. 


# Caveat
  Il database implica una relazione di tipo uno-a-uno tra i geni e le proteine, ovvero un gene codifica per una e una sola proteina. Ciò non è necessariamente vero e perciò il database andrebbe corretto in tal senso.


# Autori del progetto

  Iacuone Diego
  
  Odierno Aurora
  
  Pachiarotti Giulio
