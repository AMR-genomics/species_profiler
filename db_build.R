#!/usr/bin/env Rscript

genomes_dir <- "/app/genomes"
db_dir <- "/app/db"


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Load the list of reference genome downloaded from NCBI
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
library(tidyverse)
ss <- read_tsv(file.path(genomes_dir,"db_accession.tsv"),col_types = cols("Organism Taxonomic ID"="c")) |>
	left_join(
		list.files(genomes_dir,"_genomic.fna$",recursive = TRUE,full.names = TRUE) |>
			enframe(value = "src_path",name=NULL) |>
			mutate(`Assembly Accession`=basename(dirname(src_path)))
	) |>
	mutate(db_path=str_glue('fna/{`Assembly Accession`}.fna')) |>
	mutate(db_abs_path=file.path(db_dir,db_path))

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Copy the FASTA to the DB folder with appropriate renaming
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
dir.create(file.path(db_dir,"fna"),recursive = TRUE)
file.copy(ss$src_path,file.path(db_dir,ss$db_path),overwrite = TRUE)

# Generate Reference List file for fastANI, with FASTA filenames to consider
writeLines(ss$db_abs_path,con = file.path(db_dir,"fastANI.rl"))


# Build db annotation table
message("generate db.tsv")
db <- ss |>
	select(assembly_acc=`Assembly Accession`,org_name=`Organism Name`,tax_id=`Organism Taxonomic ID`)
write_tsv(db,file = file.path(db_dir,"db.tsv"),na="")



