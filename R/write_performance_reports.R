library(dplyr)

#' @export
write_performance_reports = function(routes, od_table_file = "od_table0.tsv") {
	dir.create("../out")
	readr::write_csv(routes, "../out/routes.csv", na = "0")

	customers = read_customers() %>%
		dplyr::select(customer_id, point_id, service_time, customer_name)
	od_table = read_od_table(od_table_file)
	end_points = start_end_points(routes)
	points = read_points()

	twc = trips_with_costs(routes, customers, od_table, end_points, points)
	cv = customers_with_visits(twc)
	cv2 = cv %>%
		dplyr::inner_join(days, by = "week_day") %>%
		dplyr::select(customer_id, day, visits)
  ##>    customer_id day      visits
  ##>          <dbl> <chr>     <int>
  ##>  1         206 monday        1
  ##>  4         552 tuesday       1
  ##>  5         552 saturday      1
	cvpd = customer_visits_per_day(cv)
	rc = routes_with_costs(twc)
	tc = total_costs(rc)
	crf = convert_to_customer_routes_format(routes, days)

	readr::write_tsv(twc, "../out/trips_with_costs.tsv", na = "0")
	readr::write_tsv(cv, "../out/customers_with_visits.tsv", na = "0")
	readr::write_tsv(cv2, "../out/customers_with_visits2.tsv", na = "0")
	readr::write_tsv(cvpd, "../out/customer_visits_per_day.tsv", na = "0")
	readr::write_tsv(rc, "../out/routes_with_costs.tsv", na = "0")
	readr::write_tsv(tc, "../out/total_costs.tsv", na = "0")
	readr::write_tsv(crf, "../out/rotalar.tsv", na = "")
	x0 = list(twc, cv, cv2, cvpd, rc, tc, crf, routes)
	WriteXLS::WriteXLS(x0, "../out/report.xlsx", SheetNames = c("trips", "visits", "visits2", "visits_day", "routes_costs", "total", "rotalar", "routes"))
}

#' @export
convert_to_customer_routes_format = function(routes, days) {
	crf = routes %>%
		left_join(days, by = "week_day") %>%
		select(
			TerritoryId = salesman_id
			, WeekDay = gun
			, LocationId = customer_id
			, Sequence = sequence_no
	  )
}

#' @export
trips_with_costs = function(routes, customers, od_table, end_points, points) {
	r1 = routes %>%
		dplyr::left_join(customers, by = "customer_id") 

	r2 = dplyr::bind_rows(r1, end_points) %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::arrange(salesman_id, week_day, sequence_no) %>%
		dplyr::mutate( to_point_id = dplyr::lead(point_id) ) %>%
		dplyr::rename( from_point_id = point_id )
		##>    salesman_id week_day  customer_id sequence_no from_point_id to_point_id
		##>          <dbl> <chr>           <dbl>    <dbl>         <dbl>       <dbl>
		##>  1           7 ÇARŞAMBA            0        0             1          58
		##>  2           7 ÇARŞAMBA         8267        1            58        2539
		##> ...
		##> 16           7 ÇARŞAMBA       370498       15          2039           1
		##> 17           7 ÇARŞAMBA            0      100             1          NA
		##> 18           7 CUMA                0        0             1        1759

  # remove last route steps which is from 1 to NA
	r3 = r2 %>%
		dplyr::filter(sequence_no != 100)
	r4 = r3 %>%
		dplyr::left_join(od_table, by = c("from_point_id", "to_point_id")) %>%
		dplyr::rename(trip_duration = duration) %>%
		dplyr::mutate(duration = service_time + trip_duration)
  ##>    salesman_id week_day customer_id sequence_no from_point_id to_point_id duration distance
  ##>          <dbl>    <dbl>       <dbl>       <dbl>         <dbl>       <dbl>    <dbl>    <dbl>
  ##>  1           7        0           0           0             1          73    20.6    22.5
  ##>  2           7        0       11285           1            73          92     1.68    0.779
	r9 = r4 %>%
		dplyr::left_join(points, by = c("from_point_id" = "point_id")) %>%
		dplyr::rename(from_lat = lat, from_lng = lng) %>%
		dplyr::left_join(points, by = c("to_point_id" = "point_id")) %>%
		dplyr::rename(to_lat = lat, to_lng = lng)

	return(r9)
}

#' @export
customers_with_visits = function(trips_w_costs) {
	r7 = trips_w_costs %>%
		dplyr::group_by(customer_id, week_day) %>%
		dplyr::summarize(
			visits = dplyr::n()
		) %>%
		dplyr::filter(customer_id != 0)
	return(r7)
  ##>    customer_id week_day visits
  ##>          <dbl>    <dbl>  <int>
  ##>  1         206        0      1
  ##>  2         296        0      1
	##> tsv:
  ##> 14254	0	1
  ##> 14254	5	1
}

#' @export
customer_visits_per_day = function(customers_with_visits) {
	cvv = customers_with_visits %>%
		dplyr::group_by(customer_id) %>%
		dplyr::summarize(visits = sum(visits))
	r8 = customers_with_visits %>%
		tidyr::spread(week_day, visits) %>%
		dplyr::rename(
			monday = 2
			, tuesday = 3
			, wednesday = 4
			, thursday = 5
			, friday = 6
			, saturday = 7
		) %>%
		dplyr::inner_join(cvv, by = "customer_id")
  ##>    customer_id monday tuesday wednesday thursday friday saturday visits
  ##>          <dbl>  <int>   <int>     <int>    <int>  <int>    <int>  <int>
  ##>  1         206      1      NA        NA       NA     NA       NA      1
  ##>  2         296      1      NA        NA       NA     NA       NA      1
  ##>  4         552     NA       1        NA       NA     NA        1      2
	return(r8)
}

#' @export
routes_with_costs = function(trips_w_costs) {
	r5 = trips_w_costs %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::summarize(
			route_duration = sum(duration)
			, route_distance = sum(distance)
			, visits = dplyr::n() - 1
			, route_service_time = sum(service_time)
			, assumed_trip_time = 510 - route_service_time
			, avg_speed = route_distance / assumed_trip_time * 60
		) %>%
		ungroup() %>%
		dplyr::mutate(route_id = dplyr::row_number()) %>%
		dplyr::select(route_id, dplyr::everything())
  ##>    route_id salesman_id week_day duration distance visits
  ##>       <int>       <dbl>    <dbl>    <dbl>    <dbl>  <dbl>
  ##>  1        1           7        0     98.9     83.0     24
  ##>  2        2           7        1    157.     155.      24
	return(r5)
}

#' @export
total_costs = function(routes_w_costs) {
	rs = dplyr::tibble(
		total_duration = sum(routes_w_costs$route_duration, na.rm = T)
		, total_distance = sum(routes_w_costs$route_distance, na.rm = T)
		, total_visits = sum(routes_w_costs$visits, na.rm = T)
		, mean_duration = mean(routes_w_costs$route_duration, na.rm = T)
		, mean_distance = mean(routes_w_costs$route_distance, na.rm = T)
		, mean_visits = mean(routes_w_costs$visits, na.rm = T)
	)
	return(rs)
}

#' @export
start_end_points = function(routes) {
	salesman_ids = get_salesman()$salesman_id %>% unique
	week_days = routes$week_day %>% unique
	si = dplyr::tibble(salesman_id = salesman_ids)
	wd = dplyr::tibble(week_day = week_days)
	d2 = tidyr::crossing(si, wd) 
  ##>    salesman_id week_day
  ##>          <dbl>    <dbl>
  ##>  1           7        0
  ##>  2           7        1
  ##>  3           7        2
  ##>  4           7        3
  ##>  5           7        4
  ##>  6           7        5
  ##>  7          12        0
	d3 = d2 %>%
		dplyr::mutate(
			customer_id = 0
			, sequence_no = 0
			, point_id = 1
			, service_time = 0
		)
  ##>    salesman_id week_day customer_id sequence_no point_id service_time
  ##>          <dbl>    <dbl>       <dbl>       <dbl>    <dbl>        <dbl>
  ##>  1           7        0           0           0        1            0
  ##>  2           7        1           0           0        1            0
	d4 = d2 %>%
		dplyr::mutate(
			customer_id = 0
			, sequence_no = 100
			, point_id = 1
			, service_time = 0
		)
	d5 = dplyr::bind_rows(d3, d4)
	
	rd = routes %>%
		dplyr::distinct(salesman_id, week_day) 
	d6 = d5 %>%
		dplyr::inner_join(rd, by = c("salesman_id", "week_day"))
	return(d6)
}

