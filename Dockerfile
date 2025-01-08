#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# base container with R and tidyverse
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM rocker/r-ver:4.4.1 AS base
RUN /rocker_scripts/install_tidyverse.sh
RUN apt-get update && apt-get install -y \
      libglpk-dev \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*;
RUN install2.r --error --skipinstalled --ncpus -1 \
        tidygraph optparse ggraph openxlsx \
    && rm -rf /tmp/downloaded_packages

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Download genomes and taxonomy from NCBI
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM staphb/ncbi-datasets:16.30.0 AS genomes
WORKDIR /data/
RUN mkdir -p genomes/

# Download some complete reference genomes
RUN datasets download genome taxon 'Enterobacterales' --reference --assembly-level complete --filename Enterobacterales.zip \
    && unzip Enterobacterales.zip -d genomes/Enterobacterales
RUN datasets download genome taxon 'Pseudomonas aeruginosa' --reference --assembly-level complete --filename Paeruginosa.zip \
    && unzip Paeruginosa.zip -d genomes/Paeruginosa
RUN datasets download genome taxon 'Acinetobacter baumannii' --reference --assembly-level complete --filename Abaumannii.zip \
    && unzip Abaumannii.zip -d genomes/Abaumannii
RUN datasets download genome taxon 'Enterococcus' --reference --assembly-level complete --filename Enterococcus.zip \
    && unzip Enterococcus.zip -d genomes/Enterococcus
RUN datasets download genome taxon 'Staphylococcus' --reference --assembly-level complete --filename Staphylococcus.zip \
    && unzip Staphylococcus.zip -d genomes/Staphylococcus
RUN datasets download genome taxon 'Streptococcus' --reference --assembly-level complete --filename Streptococcus.zip \
    && unzip Streptococcus.zip -d genomes/Streptococcus

# Download additional uncomplete reference genomes
RUN datasets download genome taxon 'Enterococcus faecalis' --reference --filename Efaecalis.zip && unzip Efaecalis.zip -d genomes/Efaecalis
RUN datasets download genome taxon 'Citrobacter murliniae' --reference --filename Cmurliniae.zip && unzip Cmurliniae.zip -d genomes/Cmurliniae

# Make the tsv file with all accession numbers
RUN cat genomes/*/ncbi_dataset/data/assembly_data_report.jsonl \
    | dataformat tsv genome --fields accession,organism-name,organism-tax-id,assmstats-total-sequence-len,assmstats-total-number-of-chromosomes \
    > genomes/db_accession.tsv


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Prepare the database from downloaded genomes
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base AS db
COPY --from=genomes /data/genomes /app/genomes
COPY --chmod=755 db_build.R /app/
RUN cd /app && ./db_build.R


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Main
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base AS species_profiler
COPY --from=staphb/fastani:1.34 /usr/local/bin/fastANI /app/
COPY --from=db /app/db /app/db
COPY bin /app/bin

VOLUME /cwd
WORKDIR /cwd
ENV PATH=$PATH:/app/bin
ENTRYPOINT []
