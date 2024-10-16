#!/usr/bin/env bash


DBDIR=genome

# Download NCBI taxonomy
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz && mkdir -p genomes/taxdump && tar -C genomes/taxdump -zxf taxdump.tar.gz

# Download genomes
datasets download genome taxon 'Pseudomonas aeruginosa' --reference --assembly-level complete --filename Paeruginosa.zip && unzip Paeruginosa.zip -d genomes/Paeruginosa
datasets download genome taxon 'Acinetobacter baumannii' --reference --assembly-level complete --filename Abaumannii.zip && unzip Abaumannii.zip -d genomes/Abaumannii
datasets download genome taxon 'Enterococcus faecalis' --reference --filename Efaecalis.zip && unzip Efaecalis.zip -d genomes/Efaecalis
datasets download genome taxon 'Enterococcus faecium' --reference --assembly-level complete  --filename Efaecium.zip && unzip Efaecium.zip -d genomes/Efaecium
datasets download genome taxon 'Staphylococcus aureus' --reference --assembly-level complete  --filename Saureus.zip && unzip Saureus.zip -d genomes/Saureus
#datasets download genome taxon 'Enterobacterales' --reference --assembly-level complete --filename Enterobacterales.zip && unzip Enterobacterales.zip -d genomes/Enterobacterales

# Make the tsv file with all accession numbers
cat */ncbi_dataset/data/assembly_data_report.jsonl | dataformat tsv genome --fields accession,organism-name,organism-tax-id,assmstats-total-sequence-len,assmstats-total-number-of-chromosomes > db_accession.tsv

