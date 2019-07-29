#!/bin/bash
file_path=$1
R --vanilla -e "pvrpr::main_write_reports(file_path = '${file_path}', od_table_file = 'od_table0.tsv')"

