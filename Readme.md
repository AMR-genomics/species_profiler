
# Introduction

`species_profiler` detects Enterobacterales species in assembled genome.
It uses `FastANI`to compute Average Nucleotide Identity between 
given assemblies and 283 Enterobacterales genomes taken from NCBI and reformat
the output to include NCBI taxonomy informations.

# Usage

To use the tool, you need to mount the working directory on `/cwd`.
```bash
docker run --rm -it -v .:/cwd unigebsp/species_profiler bash
```


# Building

Before building, we use the scripts `data/ncbi_download.sh` to retrieve the genomes 
from NCBI and the taxonomy tree (`taxdump`). Then `build_db.R` is used to generate 
the database folder `app/db`.

```bash
# Run 
docker run --rm -v ./data/:/data --platform linux/amd64 staphb/ncbi-datasets:16.30.0 ./ncbi_download.sh
docker build --platform linux/amd64 -t unigebsp/species_profiler ./
```

