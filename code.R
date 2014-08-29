library(rCharts)


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
