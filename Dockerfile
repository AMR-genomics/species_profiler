
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
FROM rocker/r-ver:4.4.1 AS app_db
RUN /rocker_scripts/install_tidyverse.sh
RUN install2.r --error --skipinstalled --ncpus -1 \
        tidygraph \
    && rm -rf /tmp/downloaded_packages
COPY --from=genomes /data/genomes /app/genomes
COPY db_build.R /data
RUN ./db_build.R


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Main
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM rocker/r-ver:4.4.1

RUN install2.r --error --skipinstalled --ncpus -1 \
      readr dplyr stringr optparse \
    && rm -rf /tmp/downloaded_packages

COPY --from=staphb/fastani:1.34 /usr/local/bin/fastANI /app/
ADD app /app

VOLUME /cwd
WORKDIR /cwd
ENTRYPOINT ["/app/species_profiler"]
