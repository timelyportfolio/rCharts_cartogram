library(rCharts)


carto <- rCharts$new()

carto$setLib(".")
carto$lib = "carto"
carto$LIB$name = "carto"


carto$set(
  map = "./world-50m.json"  #url to the topojson source
)

carto