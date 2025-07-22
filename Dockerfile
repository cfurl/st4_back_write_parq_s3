FROM rocker/r-ver:4.2.2

RUN mkdir -p /home
RUN mkdir -p /home/code
RUN mkdir -p /home/data

WORKDIR /home

# COPY .Renviron /home
COPY /code/write_parq_2_s3.R /home/code/write_parq_2_s3.R
COPY /code/install_packages.R /home/code/install_packages.R
COPY /data/texas_buffer_spatial_join.csv /home/data/texas_buffer_spatial_join.csv

RUN Rscript /home/code/install_packages.R

CMD Rscript /home/code/write_parq_2_s3.R