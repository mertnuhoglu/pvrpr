#!/bin/bash
R --vanilla -e "pvrpr::write_trips_with_route_geometry(pvrpr::trips_with_curl_cmd())"
