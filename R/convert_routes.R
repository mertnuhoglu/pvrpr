rotalar_mevcut_2_routes = function(rotalar_mevcut) {
	salesman = get_salesman() %>%
		dplyr::select(salesman_id, salesman_no)
	routes_normal = rotalar_mevcut %>%
		dplyr::rename(
			salesman_id = TerritoryId
			, gun = WeekDay
			, customer_id = LocationId
			, sequence_no = Sequence
		) %>%
		dplyr::left_join(days, by = "gun") %>%
		dplyr::left_join(salesman, by = "salesman_id") %>%
		dplyr::select(sequence_no, customer_id, salesman_id, week_day)
	return(routes_normal)
}

routes_algo_2_routes_normal = function(routes) {
	# input: routes from pvrp algorithm
	# output: normalized routes
	routes_normal = routes %>%
		dplyr::select(day_no,salesman_no,sequence_no,customer_id) %>%
		dplyr::rename(
			week_day = day_no
		) %>%
		dplyr::left_join(get_salesman(), by = "salesman_no") %>%
		dplyr::select(salesman_id, week_day, customer_id, sequence_no)
  ##>    salesman_id week_day customer_id sequence_no
  ##>          <dbl>    <dbl>       <dbl>       <dbl>
  ##>  1           7        0       29465           1
  ##>  2           7        0       95309           2
	return(routes_normal)
}

rotalar_to_routes_algo = function(rotalar) {
	salesman = get_salesman()
	routes = rotalar %>%
		dplyr::select(
			gun = WeekDay
			, salesman_id = TerritoryId
			, sequence_no = Sequence
			, customer_id = LocationId
		) %>%
		dplyr::left_join(salesman, by = "salesman_id") %>%
		dplyr::select(-salesman_id) %>%
		dplyr::left_join(days, by = "gun") %>%
		dplyr::select(day_no = week_day, salesman_no, sequence_no, customer_id) %>%
		dplyr::arrange(day_no, salesman_no, sequence_no)
}

