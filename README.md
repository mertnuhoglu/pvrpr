# pvrpr

## Setup pvrpr

Dependencies are installed in `~/projects/itr/fmcgvrp/pvrp/scripts/install_software_common.sh`

``` bash
git clone git@bitbucket.org:mertnuhoglu/pvrpr.git
cd pvrpr
make build
``` 

# Generate reports

## Write performance reports

Follow `~/projects/itr/fmcgvrp/pvrp/doc/verifications_fmcgvrp.md`

## Generate geometry data

`pvrp` rotaları optimize ediyor. Ancak bu rotaların geometrilerini (yani harita üzerindeki polyline şekillerini) çizmek için, geometry json dosyalarını indiriyoruz ve sonra da bunlardan geometry datasını çekiyoruz.

### opt01: Download geometry json files and write geometry files

Eğer geometry json dosyalarını henüz indirmediysek:

``` bash
bash ~/projects/itr/fmcgvrp/pvrpr/scripts/main_write_geometry.sh
``` 

### Write geometry files from geometry json files

Eğer geometry json dosyaları hazırda bulunuyorsa:

``` bash
bash ~/projects/itr/fmcgvrp/pvrpr/scripts/write_trips_with_route_geometry.sh
``` 

