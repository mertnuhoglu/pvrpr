library(dplyr)

#' @export
musteriler_tsv_2_normal = function(musteriler_df) {
	d0 = musteriler_df %>%
		dplyr::rename(
			location_id = LocationId
			, name = Name
			, lat = Lat
			, lon = Lon
			, opening_time = OpeningTime
			, closing_time = ClosingTime
			, service_time = ServiceTime
			, weekly_visit_frequency = WeeklyVisitFrequency
			, monday = Monday
			, tuesday = Tuesday
			, wednesday = Wednesday
			, thursday = Thursday
			, friday = Friday
			, saturday = Saturday
			, revenue = Revenue
			, channel = Channel
		) %>%
		dplyr::mutate(point_id = row_number()) 
	points = d0 %>%
		dplyr::select(point_id, lat, lon)
	customers = d0 %>%
		dplyr::filter(location_id != 'Depo') %>%
		dplyr::select(
			customer_id = location_id
			, customer_name = name
			, opening_time:channel
			, point_id
		)
	depots = d0 %>%
		dplyr::filter(location_id == 'Depo') %>%
		dplyr::select(
			depot_id = location_id
			, name
			, point_id
		)
	return(list(points = points, customers = customers, depots = depots))
}

#' @export
stlistesi_2_salesman = function(stlistesi_df) {
	salesman = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/stlistesi.tsv")) %>%
		dplyr::rename( salesman_id = TerritoryId) %>%
		dplyr::mutate( salesman_no = dplyr::row_number() - 1) %>%
		dplyr::select( salesman_id, salesman_no )
}

main = function() {
	musteriler_tsv = glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/musteriler.tsv")
	ndir = file.path(dirname(musteriler_tsv), "normal")
	musteriler_df = readr::read_tsv(musteriler_tsv)
	nd = musteriler_tsv_2_normal(musteriler_df)

	stlistesi_df = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/stlistesi.tsv"))
	salesman = stlistesi_2_salesman(stlistesi_df)

	dir.create(path = ndir, recursive = T)
	readr::write_tsv(nd$points, path = file.path(ndir, "points.tsv"), na ="")
	readr::write_tsv(nd$customers, path = file.path(ndir, "customers.tsv"), na ="")
	readr::write_tsv(nd$depots, path = file.path(ndir, "depots.tsv"), na ="")
	readr::write_tsv(salesman, path = file.path(ndir, "salesman.tsv"), na ="")
}

