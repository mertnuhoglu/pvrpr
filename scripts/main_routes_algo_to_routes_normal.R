#!/usr/bin/env Rscript
library(dplyr)
file_path = "/Users/mertnuhoglu/gdrive/mynotes/prj/itr/iterative_mert/fmcgvrp/gen/report_20190610_mevcut/routes_algo.csv"
routes_normal = readr::read_csv(file_path) %>%
	pvrpr::routes_algo_2_routes_normal()
readr::write_csv(routes_normal, "/Users/mertnuhoglu/gdrive/mynotes/prj/itr/iterative_mert/fmcgvrp/gen/report_20190610_mevcut/routes.csv")
