# New features and optimizations for animint
Jun Cai  
March 15, 2015  

# 1 Background

[Animint]([https://github.com/tdhock/animint]) is an R package for making interactive animated data
visualizations on the web, using ggplot syntax and 2 new aesthetics:

- **showSelected=variable** means that only the subset of the data that
  corresponds to the selected value of **variable** will be shown.
- **clickSelects=variable** means that clicking a plot element will
  change the currently selected value of **variable**.

Toby Dylan Hocking initiated the project in 2013, and Susan VanderPlas
(2013) and Carson Sievert (2014) have provided important contributions
during previous GSOC projects.

# 2 Related work

Standard R graphics are based on the pen and paper model, which makes
animations and interactivity difficult to accomplish. Some existing
packages that provide interactivity and/or animation are

- Non-interactive animations can be accomplished with the [animation](http://yihui.name/animation/)
  package (animint provides interactions other than moving
  forward/back in time).
- Some interactions with non-animated linked plots can be done with
  the [qtbase, qtpaint, and cranvas packages](https://github.com/ggobi/cranvas/wiki) (animint provides
  animation and showSelected).
- Linked plots in the web are possible using [SVGAnnotation](http://www.omegahat.org/SVGAnnotation/SVGAnnotationPaper/SVGAnnotationPaper.html) or [gridSVG](http://sjp.co.nz/projects/gridsvg/), but using these to create such a visualization requires knowledge of Javascript (animint designers write only R/ggplot2 code). 
- The [svgmaps](https://r-forge.r-project.org/scm/viewvc.php/pkg/?root=svgmaps) package defines interactivity (hrefs, tooltips) in R code using igeoms, and exports SVG plots using gridSVG, but does not
  support showing/hiding data subsets (animint does). 
- The [ggvis](https://github.com/rstudio/ggvis) package defines a grammar of interactive graphics that is
  limited to a single plot (animint does several linked plots).
- [Vega](https://github.com/trifacta/vega) can be used for describing plots in Javascript, but does not
  implement clickSelects/showSelected (animint does).
- [RIGHT](http://cran.r-project.org/web/packages/RIGHT/) and [DC](http://dc-js.github.io/dc.js/) implement interactive plots for some specific plot types (animint uses the multi-layered grammar of graphics so is not
  limited to pre-defined plot types).

For even more related work see the [Graphics](http://cran.r-project.org/web/views/Graphics.html) and [Web technologies](http://cran.r-project.org/web/views/WebTechnologies.html) task views on CRAN, and [Visualization design resources from the UBC InfoVis Group](http://www.cs.ubc.ca/group/infovis/resources.shtml).

# 3 Project goals

The project aims to implement several new features and optimize the compilation for animint. It will also fix the bugs that I uncovered while creating in my project tests.

### New features

- New aesthetics that only make sense on the web/SVG (not in ggplot2), for example an aesthetic for [stroke-opacity and fill-opacity](https://github.com/tdhock/animint/issues/32).

- Currently, selected items in animint are shown with a black border outline stroke for rectangles, and with 0.5 more alpha transparency for all other geoms. This should be configurable using new aesthetics such as selected.color, selected.alpha, etc.

- ggplot2 in R provides 26 shape symbol types, while D3 only has 6 built in symbol types. Since D3 does not support many R shape types, the mapping between the two is diffcult and the `shape` aesthetic is currently unsupported in animint.

- The `arrow` aesthetic in `geom_path()` or `geom_segment()` is not supported in animint. To implement the [demonstration of gradient descent algorithm](http://tonytsai.name/grad.desc/index.html) from animation package, I had to replace the arrow with point symbol.

### Optimization

- It takes so much time and memory to compile large data. It took more than 300 seconds to compile my [CDC flu data visualization](http://tonytsai.name/FluView/index.html). It is also reported in the TODO list that it took 15 minutes to compile the [scaffolds](https://github.com/tdhock/animint-examples/blob/master/examples/scaffolds.R) example and a computer equipped with 12 GB RAM started swapping when compiling the [vervet](https://github.com/tdhock/animint/blob/master/inst/examples/vervet.R) example.

- `animint2gist()` successfully uploaded the demostration of gradient descent algorithm visualization to the web; however,  an ``Error: x$headers$`content-type` == "application/json; charset=utf-8" is not TRUE`` occurred when uploading the CDC flu data visualization. My CDC flu data visualization generated 435 chunck TSVs and produced an output directory with a large size of 220.3 MB. It failed to upload such large amount of chunck files to the web maybe due to the limiatations of transfer speed and bandwidth.

- As shown in the case of my CDC flu data visualization, when there are many SVG elements (or paths with many control points, e.g. polygon shapes), the web browser slows down and leads to long delays for animated and interactive plot updates.

### Bug fixing

- While using animint to implement the [demonstration of gradient descent algorithm](http://tonytsai.name/grad.desc/index.html) from animation package, I found that the `hjust` and `vjust` arguments were not supported in `geom_text()` or `make_text()`. It fails to pass the testthat unit test of [`test-hjust-text-anchor.R`](https://github.com/tdhock/animint/pull/43) since the `hjust` is treated as "data" rather than "params" in the renderer code.

- While creating my CDC flu data visualization, I found that `make_text()` or `geom_text()` could not annotate text out the bound of axis. This is a reported [bug](https://github.com/hadley/ggplot2/issues/905) of base `ggplot2`. 

# 4 Implementation

### New features

- The D3 aesthetics that aren't available in R could be added as new aethetics in a way of `d3.aesthetic`. When compiling an animint, those aesthetics beginning with `d3.` would be directly coverted into corresponding web/SVG aesthetics. The [stroke-opacity and fill-opacity](https://github.com/tdhock/animint/issues/32) issue could actually be solved using following new feature. 

- The aesthetics for rectangle shape supported in D3 could be added to rectangles of selected variable by new aesthetics in a way of `selected.*`. For example, the `selected.color` and `selected.alpha` aesthetic for rectangles of selected variable could be supported via `fill` and `opacity` style of `<rect>` elements, respectively.

- The `shape` aesthetic for animint could be fully supported by mapping R shape types to D3 built-in and custom symbol types. The R shape types that aren't supported by D3 built in symbol types can be defined by primitive D3 shapes (e.g., `SVG:polyline` and `SVG:polygon`). The StackOverflow [question](http://stackoverflow.com/questions/25332120/create-additional-d3-js-symbols) gives the basic routine of creating additional symbols in D3. A workaround would be to create a map of custom symbol definitions, and create a custom symbol function based on the D3 source code for the built-in symbols. Then, a function was created to render the R shapes into D3 symbols by checking whether the `shape` parameter refers to a bulit-in symbol. If it's not, custom symbol definitions are used for rendering. 

- The `arrow` aesthetic to `geom_path()` or `geom_segment()` could be supported in D3 via the [Basic Directional Force Layout Diagram](http://bl.ocks.org/d3noob/5141278) example.

### Optimization

- Profile `animint2dir()` or `animint2gist()` to see which line numbers and particular function calls are slow, and rewrite them in efficient way such as vectorization. Particularly, for compiling large data, e.g. my CDC flu data visualization, it's better to generate chunk TSVs in a parallel way. A `.parallel` option in `animint2dir()` or `animint2gist()` should be provided for users.

- With servers like gist.github.com, all .json files are served with Content-Encoding: gzip and they use
[HTTP compression](http://en.wikipedia.org/wiki/HTTP_compression) over the network. Compressing the chunck TSV files can not only save disk space, but also improve the uploading of `animint2gist()`. It can also reduce the time of dowloading selected chunck TSV file and help to achieve smooth animation and interaction.

- When using ggplot2 to draw maps, spatial objects are stored in data.frame, in which each row consists of coordinates of a vertex and attributes of the spatial object (e.g. fill colors of state polygons). ESRI shapefile separately stores the shape and attribute in .shp and .dbf table, avoiding the repeated storage of shape coordinates. For example, in my CDC flu data visualization, it generates 335 chunck TSV files for `geom_polygon(aes(stateMap))` and each TSV has 11470 rows (number of vertex). If animint generates chunck files in the way of separetely storing shapes and attributes, it will generate 336 chunck TSV files. The extra chunck file will have 11470 rows to store the geographic coordinates of state polygons and an extra `id` (e.g. state name) column. Each of the remaining chunck files will have only 48 rows (number of lower states) to only store the attributes of each state and extra `id` column. The shape and attribute will be merged by `id` column before rendering maps. The merge operation can be performed at web browser after downloading the selected chunck file. The shape chunck file will be loaded only once on the visualization startup. The optimization of animint compiler for storing chunck files is most effective for data.frame with the property of storing spatial objects (e.g. polylines and polygons), which will dramatically decrease the size of chunck files.

### Bug fixing

- The `hjust` aesthetic to `geom_text()` or `make_text()` should be supported via text-anchor style of `<text>` elements. The valid values for `hjust` are `0`, `0.5`, and `1`, corresponding to the text style `start`, `middle`, and `end`, respectively.

# 5 Timeline

- Familiarize myself with the animint source code and fix `hjust` bug. (End of April)
- Add new aesthetics that only make sense for web/SVG. (Middle of May)
- Add new aesthetics for rectangles of selected variable. (End of May)
- Implement `shape` and `arrow` aesthetics. (Middle of June)
- Produce examples, write testthat unit tests for new functions, and prepare for mid-term evals. (End of June)
- Speed `animint2dir` or `animint2gist` up by vectorization and parallel compilation. (Middle of July)
- Add new approach of generating chunck files and compression option. (End of July)
- Produce examples and write testthat unit tests for new functions. (First week of August)
- Clean code and write documents (Second week of August)

# 6 About me

I began to use R since 2012 and now I am an enthusiast of R. I am the author of R package [geoChina](https://github.com/caijun/geoChina) and have the experience of R pakcage development. Recently I and co-workers have translated R Graphics (2nd edition) by Paul Murrell into Chinese, which will get published later this year. I am responsible for the translations of chapter 14 ~ 19, including chapter 17 Dynamic and Interactive Graphics.

Email:<tony.tsai.2046@gmail.com>

github: <https://github.com/caijun>

Blog:<http://blog.tonytsai.name>
