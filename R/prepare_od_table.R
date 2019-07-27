library(dplyr)
library(jsonlite)

prepare_od_table = function(od_json) {
	j0 = jsonlite::fromJSON(od_json)
	dis0 = j0$distances
	dur0 = j0$durations
	dur1 = matrix_to_tibble(dur0) %>%
		dplyr::mutate(duration = duration / 60)
	dis1 = matrix_to_tibble(dis0) %>%
		dplyr::rename(distance = duration) %>%
		dplyr::mutate(distance = distance / 1000)
	r0 = dur1 %>%
		inner_join(dis1, by = c("from_point_id", "to_point_id"))
	return(r0)
}

matrix_to_tibble = function(mat) {
	n = dim(mat)[1]
	dimnames(mat) = list(c(1:n), c(1:n))
	d1 = as.table(mat)
	d2 = as.data.frame(d1) %>%
		dplyr::rename(
			from_point_id = Var1
			, to_point_id = Var2
			, duration = Freq
		) %>%
		filter(from_point_id != to_point_id) %>%
		dplyr::arrange(from_point_id, to_point_id)
  # Convert factors to characters
	d3 = data.frame(lapply(d2, as.numeric))
}

test_main = function() {
	od_json = glue::glue("{PEYMAN_PROJECT_DIR}/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/ex13.json")
	r0 = prepare_od_table(od_json)
	readr::write_tsv(r0, glue::glue("{PEYMAN_PROJECT_DIR}/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/od_table.tsv"))
}

main = function() {
	od_json = "$PEYMAN_FILES_DIR/gen/origin_destination.json"
	r0 = prepare_od_table(od_json)
	readr::write_tsv(r0, "~/gdrive/mynotes/prj/itr/iterative_mert/peyman/gen/od_table.tsv")
}
