library(dplyr)

#' @export
FMCGVRP_PROJECT_DIR = Sys.getenv("FMCGVRP_PROJECT_DIR")
#' @export
FMCGVRP_FILES_DIR = Sys.getenv("FMCGVRP_FILES_DIR")

#' @export
get_salesman = function() {
	readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/normal/salesman.tsv")) %>%
		dplyr::select( salesman_id, salesman_no )
}

#' @export
read_customers = function() {
	c0 = readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/normal/customers.tsv")) %>%
		dplyr::select(customer_id, customer_name, point_id, service_time, weekly_visit_frequency, monday, tuesday, wednesday, thursday, friday, saturday)
}

#' @export
read_od_table = function(file_name = "od_table0.tsv") {
	od = readr::read_tsv(glue::glue("{FMCGVRP_FILES_DIR}/gen/{file_name}"))
}

#' @export
read_points = function() {
	pt = readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/normal/points.tsv"))
}

#' @export
days = dplyr::tibble(
	week_day = 0:5
	, day = c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
	, gun = c("PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ")
)
