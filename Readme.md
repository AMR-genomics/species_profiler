
# Introduction

`species_profiler` detects Enterobacterales species in assembled genome.
It uses `FastANI`to compute Average Nucleotide Identity between 
given assemblies and 283 Enterobacterales genomes taken from NCBI and reformat
the output to include NCBI taxonomy informations.

# Usage

To use the tool, you need to mount the working directory on `/cwd`.
```bash
docker run --rm -v .:/cwd unigebsp/species_profiler --help
docker run --rm -v .:/cwd unigebsp/species_profiler --out output.tsv my_assembly.fasta
```


# Building

Before building, we use the scripts `data/ncbi_download.sh` to retrieve the genomes 
from NCBI and the taxonomy tree (`taxdump`). Then `build_db.R` is used to generate 
the database folder `app/db`.

```bash
# Run
docker build --platform linux/amd64 -t unigebsp/species_profiler ./
```

