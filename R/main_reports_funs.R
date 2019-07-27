library(dplyr)

main_mevcut_rotalar = function() {
	days = dplyr::tibble(
		week_day = 0:5
		, day = c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
		, gun = c("PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ")
	)
	file_path = glue::glue("{PEYMAN_FILES_DIR}/mevcutrotalar.tsv")
	routes = readr::read_tsv(file_path) %>%
		rotalar_mevcut_2_routes()

	write_performance_reports(routes)
	write_verification_reports()
}

main_optimized_routes = function() {
	file_path = glue::glue("{PEYMAN_PROJECT_DIR}/pvrp/routes.csv")
	routes_algo = readr::read_csv(file_path) 
	dir.create("../out")
	readr::write_csv(routes_algo, "../out/routes_algo.csv")
	routes = routes_algo %>%
		routes_algo_2_routes_normal()

	write_performance_reports(routes)
	write_verification_reports()
}

