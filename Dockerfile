FROM rocker/r-ver:4.4.1

RUN install2.r --error --skipinstalled --ncpus -1 \
      readr dplyr stringr optparse \
    && rm -rf /tmp/downloaded_packages

ADD app /app
COPY --from=staphb/fastani:1.34 /usr/local/bin/fastANI /app/

VOLUME /cwd
WORKDIR /cwd
ENTRYPOINT ["/app/species_profiler"]
