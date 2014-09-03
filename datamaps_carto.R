library(Quandl)
vcData = Quandl("FBI_UCR/USCRIME_TYPE_VIOLENTCRIMERATE")

library(reshape2)
datm <- melt(vcData, 'Year', 
             variable.name = 'State',
             value.name = 'Crime'
)
datm <- subset(na.omit(datm), 
               !(State %in% c("United States")) #, "District of Columbia"))
)

datm2 <- transform(datm,
                   State = state.abb[match(as.character(State), state.name)],
                   fillKey = cut(Crime, quantile(Crime, seq(0, 1, 1/5)), labels = LETTERS[1:5]),
                   Year = as.numeric(substr(Year, 1, 4))
)

fills = setNames(
  c(RColorBrewer::brewer.pal(5, 'YlOrRd'), 'white'),
  c(LETTERS[1:5], 'defaultFill')
)

library(plyr); library(rMaps); library(rCharts)
dat2 <- dlply(na.omit(datm2), "Year", function(x){
  y = toJSONArray2(x, json = F)
  names(y) = lapply(y, '[[', 'State')
  return(y)
})

options(rcharts.cdn = TRUE)
map <- Datamaps$new()
map$set(
  dom = 'chart_1',
  scope = 'usa',
  fills = fills,
  data = dat2[[1]],
  legend = TRUE,
  labels = TRUE
)
map


options(viewer=NULL)
map$addAssets(
  jshead = paste0(getwd(),"./js/cartogram.mod.js")
)
map


map$setTemplate(afterScript = 
"
<script>
var carto = d3.cartogram()
  .projection(d3.geo.albersUsa()) //setProjection(d3.select('svg')).projection)
  .properties( function(d) {
    return chartParams.data[d.id];
  })
  .value( function(d) {
    return typeof d.properties == 'undefined' ? 0 : +d.properties.Crime;
  });
  
  /*
  Datamaps.prototype.usaTopo.objects.usa.geometries.forEach(function(d){
    d.properties = carto.properties()(d)
  });
  */




  var features = carto.features(Datamap.prototype.usaTopo, Datamap.prototype.usaTopo.objects.usa)



  //topojson.feature(Datamap.prototype.usaTopo, Datamap.prototype.usaTopo.objects.usa)
  //path.area(carto.features(Datamap.prototype.usaTopo, Datamap.prototype.usaTopo.objects.usa).features[0])



  var value = function(d) {
            return typeof d.properties == 'undefined' ? 0 : +d.properties.Crime;
          },
          values = features.features
            .map(value)
            .filter(function(n) {
              return !isNaN(n);
            })
            .sort(d3.ascending),
          lo = values[0],
          hi = values[values.length - 1];

      // normalize the scale to positive numbers
      var scale = d3.scale.linear()
        .domain([0, hi])
        .range([10, 1000]);

  // tell the cartogram to use the scaled values
      carto.value(function(d) {
        return scale(value(d));
      });

  var features = carto(Datamap.prototype.usaTopo, Datamap.prototype.usaTopo.objects.usa).features;

  d3.selectAll('.datamaps-subunits path').data(features)
      .transition().duration(2750)
      .ease('linear')
      .attr('d', carto.path);

  d3.selectAll('.labels text')
      .transition().duration(2750)
      .attr('x',function(d,i){
        return carto.path.centroid(d3.selectAll('.datamaps-subunit').data()[i])[0]
      })
      .attr('y',function(d,i){
        return carto.path.centroid(d3.selectAll('.datamaps-subunit').data()[i])[1]
      })
</script>
"
)
map