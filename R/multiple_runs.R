library(dplyr)

write_total_costs_multiple_runs = function(root_dir) {
	dirs = list.files(root_dir)
	rl = list()
	for (dir in dirs) {
		file_path = glue::glue("{root_dir}/{dir}/total_costs.tsv")
		print(file_path)
		if (!file.exists(file_path)) {
			next
		}
		tc = readr::read_tsv(file_path)
		tc$report = dir
		rl[[dir]] = tc
	}
	r0 = dplyr::bind_rows(rl)
	readr::write_tsv(r0, "total_costs_multiple_runs.tsv")
}

main_write_total_costs_multiple_runs = function() {
	write_total_costs_multiple_runs(glue::glue("{PEYMAN_FILES_DIR}/gen/server_runs"))
}
