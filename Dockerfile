#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# base container with R and tidyverse
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM rocker/r-ver:4.4.1 AS base
RUN /rocker_scripts/install_tidyverse.sh
RUN apt-get update && apt-get install -y \
      libglpk-dev \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*;
RUN install2.r --error --skipinstalled --ncpus -1 \
        tidygraph optparse ggraph \
    && rm -rf /tmp/downloaded_packages

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Download genomes and taxonomy from NCBI
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM staphb/ncbi-datasets:16.30.0 AS genomes
WORKDIR /data/
COPY db_download.sh /data/
RUN ./db_download.sh

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
COPY species_profiler /app/

VOLUME /cwd
WORKDIR /cwd
ENTRYPOINT ["/app/species_profiler"]
