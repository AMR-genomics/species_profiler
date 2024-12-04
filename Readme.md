

# Introduction

`species_profiler` detects Enterobacterales species in assembled genome.
It uses `FastANI`to compute Average Nucleotide Identity between 
given assemblies and Enterobacterales genomes taken from NCBI and reformat
the output to include NCBI taxonomy informations.


# Usage

To use the tool, you need to mount the working directory on `/cwd`. Example:
```bash
docker run --rm -v .:/cwd unigebsp/species_profiler species_profiler --out output.tsv my_assembly.fasta
```


# Building

To build the container locally, run:
```bash
docker build --platform linux/amd64 -t unigebsp/species_profiler ./
```


