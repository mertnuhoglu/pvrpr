#!/bin/bash
R --vanilla -e 'pvrpr::write_total_costs_multiple_runs(glue::glue("{pvrpr::FMCGVRP_FILES_DIR}/gen/server_runs"))'
