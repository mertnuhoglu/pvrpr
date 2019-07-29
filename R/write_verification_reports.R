#' @importFrom magrittr "%>%"
NULL


#' @export
write_verification_reports = function() {
	rc = readr::read_tsv(glue::glue("{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/routes_with_costs.tsv"))
	cv2 = readr::read_tsv(glue::glue("{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/customers_with_visits2.tsv"))
	cvpd = readr::read_tsv(glue::glue("{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/customer_visits_per_day.tsv"))

	vdr = verify_duration_of_routes(rc)
	readr::write_tsv(vdr, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verify_duration_of_routes.tsv"), na = "0")
	customers2 = read_customers() %>%
		dplyr::select(customer_id, weekly_visit_frequency, monday:saturday
		)
	day_constraints = customers2 %>%
		tidyr::gather(key = day, value = visits
			, monday, tuesday, wednesday, thursday, friday, saturday
		) %>%
		dplyr::select(customer_id, day, visits) %>%
		dplyr::filter(!is.na(visits))
  ##>    customer_id day       visits
  ##>          <dbl> <chr>      <dbl>
  ##>  1        1274 tuesday        1
  ##>  2        6786 wednesday      1
  ##>  3       27678 wednesday     -1
	must_days = day_constraints %>%
		dplyr::filter(visits == 1)
	removed_days = day_constraints %>%
		dplyr::filter(visits == -1)
	vcmd = verify_customer_must_days(cv2, must_days)
	readr::write_tsv(vcmd, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verify_customer_must_days.tsv"), na = "0")
	vcrd = verify_customer_removed_days(cv2, removed_days)
	readr::write_tsv(vcrd, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verify_customer_removed_days.tsv"), na = "0")
	vcwvf = verify_customer_weekly_visit_frequency(cvpd, customers2)
	readr::write_tsv(vcwvf, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verify_customer_weekly_visit_frequency.tsv"), na = "0")
	vvlr = verify_visits_len_of_routes(rc)
	readr::write_tsv(vvlr, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verify_visits_len_of_routes.tsv"), na = "0")

	x0 = list(vdr, vcmd, vcrd, vcwvf, vvlr)
	WriteXLS::WriteXLS(x0, glue::glue( "{pvrpr::PEYMAN_PROJECT_DIR}/pvrp/out/verifications.xlsx"), SheetNames = c("durations", "must_days", "removed_days", "visit_frequency", "length_routes"))

}

#' @export
verify_visits_len_of_routes = function(routes_w_costs) {
	vvlr = routes_w_costs %>%
		filter(visits > 25)
}

#' @export
verify_customer_must_days = function(customers_w_visits2, must_days) {
	vcmd = must_days %>%
		dplyr::anti_join(customers_w_visits2, by = c("customer_id", "day")) 
}

#' @export
verify_customer_removed_days = function(customers_w_visits2, removed_days) {
	vcrd = removed_days %>%
		dplyr::inner_join(customers_w_visits2, by = c("customer_id", "day")) 
}

#' @export
verify_customer_weekly_visit_frequency = function(customer_visits_p_day, customers2) {
	vcwvf = customer_visits_p_day %>%
		dplyr::inner_join(customers2, by = "customer_id") %>%
		dplyr::filter(weekly_visit_frequency != visits) 
}

#' @export
verify_duration_of_routes = function(routes_w_costs) {
	vdr = routes_w_costs %>%
		dplyr::filter(route_duration > 510)
}


