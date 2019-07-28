library(dplyr)

#' @export
write_route_geometry = function() {
	c0 = readr::read_tsv("../out/trips_with_costs.tsv") 
		#dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat)
	osrm_server = Sys.getenv("OSRM_SERVER")
	dir.create("../out/route_json")
	trips_w_curl_cmd = c0 %>%
		dplyr::mutate(route_url = glue::glue("http://{osrm_server}/route/v1/driving/{from_lng},{from_lat};{to_lng},{to_lat}?overview=full")) %>%
		dplyr::mutate(
			file_name = glue::glue("{from_point_id}_{to_point_id}.json")
			, curl_cmd = glue::glue("curl '{route_url}' > ../out/route_json/{file_name}")
		)

	writeLines(trips_w_curl_cmd$curl_cmd, "../out/curl_cmd.sh")
	system("bash ../out/curl_cmd.sh", intern=T)

	twrg = trips_with_route_geometry(trips_w_curl_cmd)
	sf::st_write(twrg, "../out/trips_with_route_geometry.csv", delete_dsn = T)
}

#' @export
trips_with_route_geometry = function(trips_w_curl_cmd) {
	geometry = lapply(trips_w_curl_cmd$file_name, function(f) {
		j0 = rjson::fromJSON(file=glue::glue("../out/route_json/{f}"))
		j1 = j0$routes[[1]]$geometry
	}) %>% unlist()

	t0 = trips_w_curl_cmd %>%
		dplyr::mutate(geometry_enc = geometry) %>%
		dplyr::mutate(decoded = googlePolylines::decode(geometry_enc))

	geometry_sf = lapply(t0$decoded, function(decoded_df) {
		decoded_df %>%
			dplyr::select(lon, lat) %>%
			data.matrix() %>%
			sf::st_linestring() %>%
			sf::st_sfc() %>%
			sf::st_sf()
	}) %>% do.call(rbind, .)

	result = t0 %>%
		dplyr::mutate(geometry = geometry_sf$geometry) %>%
		sf::st_sf() %>%
		dplyr::select(-decoded) %>%
		dplyr::mutate(geometry_wkt = sf::st_as_text(geometry))

	return(result)
}
