#!/usr/bin/env Rscript
source("convert_routes.R")
file_path = "/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/routes_algo.csv"
routes_normal = readr::read_csv(file_path) %>%
	routes_algo_2_routes_normal()
readr::write_csv(routes_normal, "/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/routes.csv")
