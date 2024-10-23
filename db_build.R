#!/usr/bin/env Rscript

	
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Load the list of reference genome downloaded from NCBI
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
library(tidyverse)
ss <- read_tsv("genomes/db_accession.tsv",col_types = cols("Organism Taxonomic ID"="c")) |>
	left_join(
		list.files("genomes","_genomic.fna$",recursive = TRUE,full.names = TRUE) |>
			enframe(value = "src_path",name=NULL) |>
			mutate(`Assembly Accession`=basename(dirname(src_path)))
	) |>
	mutate(db_path=str_glue('fna/{`Assembly Accession`}.fna')) |>
	mutate(db_abs_path=file.path("/app/db",db_path))

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Copy the FASTA to the DB folder with appropriate renaming
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
dir.create("app/db/fna",recursive = TRUE)
file.copy(ss$src_path,file.path("app/db/",ss$db_path),overwrite = TRUE)

# Generate Reference List file for fastANI, with FASTA filenames to consider
writeLines(ss$db_abs_path,con = "app/db/fastANI.rl")


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Prepare Taxonomy
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
library(tidygraph)

# Load complete NCBI taxonomy
read_tax <- function() {
	SN <- read_tsv("genomes/taxdump/names.dmp",col_names = c("tax_id","tax_name","name_class"),col_types="c_c___c_") |> 
		filter(name_class=="scientific name") |>
		mutate(name_class=NULL)
	N <- read_tsv("genomes/taxdump/nodes.dmp",col_names = c("tax_id","parent","rank"),col_types="c_c_c_____________________") |>
		left_join(SN,by="tax_id",relationship="one-to-one")
	tax <- tbl_graph(N,select(N,parent,tax_id),node_key = "tax_id")
	tax
}
tax <- read_tax() |>
	mutate(is_db_tax = tax_id %in% ss$`Organism Taxonomic ID`) 

# Find all ancestors of selected nodes
db_ancestors <- igraph::ego(tax,order=100,nodes=igraph::V(tax)[is_db_tax],mode="in") |> 
	map(~.x$tax_id) |>
	setNames(igraph::V(tax)[is_db_tax]$tax_id) |>
	enframe(name = "leaf_id",value = "ancestor_id") |>
	unnest(ancestor_id)


# Subset the taxonomy to selected elements and its ancestors
TAX <- tax |>
	activate(edges) |>
	filter(!edge_is_loop()) |>
	activate(nodes) |>
	mutate(is_db_ancestor = tax_id %in% db_ancestors$ancestor_id) |>
	filter(is_db_ancestor)

# Check graph topology
with_graph(TAX,graph_is_dag())
with_graph(TAX,graph_is_tree())

# Build db annotation table
db <- ss |>
	select(assembly_acc=`Assembly Accession`,org_name=`Organism Name`,tax_id=`Organism Taxonomic ID`) |>
	left_join(
		inner_join(
			select(db_ancestors,tax_id=leaf_id,id=ancestor_id),
			select(as_tibble(TAX),id=tax_id,rank=rank,name=tax_name) |>
				filter(rank %in% c("superkingdom","phylum","class","order","family","genus","species"))
		) |>
		pivot_wider(id_cols = "tax_id",names_from = "rank",values_from = c("id","name"),names_glue = "{rank}_{.value}")
	)
write_tsv(db,file = "app/db/db.tsv",na="")



# Display the taxonomy tree (for debugging purpose)
if (require(ggraph)) {
	TAX |>
		ggraph("partition",circular=TRUE) +
		geom_node_arc_bar(aes(fill = rank), size = 0.25) +
		coord_equal()
	
	TAX |>
		ggraph("tree",circular=TRUE) +
		geom_edge_link() +
		geom_node_point(aes(color=rank)) +
		coord_equal() +
		geom_node_label(aes(label=tax_name,fill = rank), size = 2)	
}

