# Implement shape aesthetic for animint
Jun Cai  
March 15, 2015  



# Background

[Animint]([https://github.com/tdhock/animint]) is an R package for making interactive animated data
visualizations on the web, using ggplot syntax and 2 new aesthetics:

- **showSelected=variable** means that only the subset of the data that
  corresponds to the selected value of **variable** will be shown.
- **clickSelects=variable** means that clicking a plot element will
  change the currently selected value of **variable**.

Toby Dylan Hocking initiated the project in 2013, and Susan VanderPlas
(2013) and Carson Sievert (2014) have provided important contributions
during previous GSOC projects.

# Related work

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

# Project goal

Geoms that draw points (e.g., `geom_point`) have a **shape** parameter in ggplots. ggplot2 in R provides 26 shape symbol types, while D3 only has 6 built in symbol types, i.e., circle, cross, diamond, square, triangle-down, and triangle-up. Since D3 does not support many R shape types, the mapping between the two is diffcult and the **shape** aesthetic is unsupported in an animint. Currently only open and closed circles are supported for point shapes in animint. The project aims to fully support the **shape** aesthetic for animint by mapping R shape types to D3 built-in and custom symbol types.

# Implementation

The R shape types that aren't supported by D3 built in symbol types can be defined by primitive D3 shapes (e.g., `SVG:polyline` and `SVG:polygon`). All R shapes can be successfully mapped into D3 built-in and custom symbol types; however, the array of symbol definitions is not accessible from the public D3 API. The symbol definitions are stored in a d3.map called `d3_svg_symbols`. The only part of this map that gets exposed to the public API is the array of keys. The definitions themselves are never exposed, so custom symbol definitions cannot be added directly as desired.

A workaround would be to create a map of custom symbol definitions, and create a custom symbol function based on the D3 source code for the built-in symbols. Then, a function was created to render the R shapes into D3 symbols by checking the **shape** parameter refers to a bulit-in symbol. If it's not, custom symbol definitions are used for rendering. The modification mainly occurred in `animint.js` and `animint.R`. This implemtation details are inspired by the StackOverflow question [`Create additional D3.js symbols`](http://stackoverflow.com/questions/25332120/create-additional-d3-js-symbols).

# Timeline

- Familiarize myself with the animint source code. (End of April)
- Create a map of custom symbol definitions for unsupported R shapes in JavaScript. (Middle of May)
- Create a custom symbol function in JavaScript and shape mapping function for animint compiler. (End of May)
- Implement **shape** aesthetic for `geom_point` function. (Middle of June)
- Test fucntions and produce examples for mid-term evals. (End of June)
- Rewrite `scale_shape_discrete` and `scale_shape_continuous` function. (Middle of July)
- Rewrite `scale_shape_identity` and `scale_shape` function. (End of July)
- Produce examples and write testthat unit tests for new functions. (First week of August)
- Clean code and write documents (Second week of August)

# About me

I began to use R since 2012 and now I am an enthusiast of R. I am the author of R package [geoChina](https://github.com/caijun/geoChina) and have the experience of R pakcage development. Recently I and co-workers have translated R Graphics (2nd edition) by Paul Murrell into Chinese, which will get published later this year. I am responsible for the translations of chapter 14 ~ 19, including chapter 17 Dynamic and Interactive Graphics.

Email:<tony.tsai.2046@gmail.com>

github: <https://github.com/caijun>

Blog:<http://blog.tonytsai.name>
