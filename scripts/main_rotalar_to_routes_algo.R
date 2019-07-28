#!/usr/bin/env Rscript
source("convert_routes.R")
rotalar = readr::read_tsv("/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/rotalar.tsv")
routes_algo = rotalar_to_routes_algo(rotalar)
readr::write_csv(routes_algo, "/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/routes_algo.csv")

