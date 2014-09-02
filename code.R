library(rCharts)
library(pipeR)
library(rlist)
library(dplyr)

carto <- rCharts$new()

carto$setLib(".")
carto$lib = "carto"
carto$LIB$name = "carto"


carto$set(
  map = "worldcountries.topojson"  #url to the topojson source
)

carto$setTemplate(
  chartDiv = "
    <{{container}} id = '{{ chartId }}' class = '{{ lib }}' style='height:100%;width:100%;'>
      <h1>Cartogram of the world's languages</h1>
      <form>
        <p>
          <label>Scale by <select id='field'></select></label>
          <span id='status'></span><br>
        </p>
      </form>
      <div id='map-container'>
        <!--img id='placeholder' alt='placeholder image for old browsers' src='placeholder.png'-->
        <svg id = 'map' style = 'height:100%; width:100%' viewbox = '0 0 {{params.width}} {{params.height}}'>
      </svg>
      </div>
    </{{ container}}>" 
  , script = "./layouts/chart_mayer.html"
)


carto$save("world_carto.html",cdn=T)




carto$setTemplate(
  chartDiv = "
    <{{container}} id = '{{ chartId }}' class = '{{ lib }}' style='height:100%;width:100%;'>
      <div id='map-container'>
        <!--img id='placeholder' alt='placeholder image for old browsers' src='placeholder.png'-->
        <svg id = 'map' style = 'height:100%; width:100%' viewbox = '0 0 {{params.width}} {{params.height}}'>
      </svg>
      </div>
    </{{ container}}>" 
  , script = "./layouts/chart.html"
)
carto$save("world_test.html",cdn=T)



library(WDI)
#get country GDP data from the World Bank
country_gdp <- WDI(country = "all", indicator = "NY.GDP.MKTP.KD", start = 2009, end = 2013)
#for now use the example from mayer cartogram to join
#eventually get all countries from the topojson
lang_pop <- read.csv( "./data/nrlangspop.csv", stringsAsFactors = F )

# do the join to make sure every country gets a value
lang_pop %>>%
  #handle Namibia where "NA" becomes R <NA>
  mutate(
    NAME = ifelse( is.na(NAME), "NA", NAME)
  ) %>>%
  merge( filter( country_gdp, year == 2013) ,by.x="NAME",by.y="iso2c",all.x = T ) %>>%
  #filter( is.na( as.numeric( NAME )  ) ) %>>%
  mutate(
    year = 2013
    , NY.GDP.MKTP.KD = ifelse( is.na( NY.GDP.MKTP.KD ), 0, NY.GDP.MKTP.KD )
  ) %>>%
  (~ data_2013 = . )


# now let's see if we can supply this data to our cartogram
carto$set(
  data = data_2013
  , x = "NY.GDP.MKTP.KD"
  #, x = "NRLANGUAGES2010"
)

carto$save("world_test2.html",cdn=T)
