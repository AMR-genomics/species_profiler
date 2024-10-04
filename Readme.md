
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

Before building, we use the script `build_db.R` to generate the database folder `app/db` from reference 
NCBI assemblies stored in `data/` and NCBI taxonomy (`taxdump`).

```bash
docker build --platform linux/amd64 -t unigebsp/species_profiler ./
```

