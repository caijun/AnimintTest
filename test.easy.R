setwd("~/Documents/R/animint")

library(cdcfluview)
library(ggplot2)

# retrieve state-level data from the CDC's FluView Portal
state_flu <- get_state_data(2008:2014)
# data clean
state_flu <- state_flu[, !names(state_flu) %in% c("URL", "WEBSITE")]
state_flu$state <- tolower(state_flu$STATENAME)
state_flu$level <- as.numeric(gsub("Level ", "", state_flu$ACTIVITY.LEVEL))
state_flu$WEEKEND <- as.Date(state_flu$WEEKEND, format = "%b-%d-%Y")
max(state_flu$WEEKEND)
state_flu <- subset(state_flu, WEEKEND <= as.Date("2015-02-28") & 
                      !STATENAME %in% c("District of Columbia", "New York City", 
                                       "Puerto Rico", "Alaska", "Hawaii"))
state <- data.frame(state = unique(state_flu$STATENAME))
state$statename <- paste(state$state, "State")
library(geoChina)
latlng <- geocode(state$statename, api = "google", ocs = "WGS-84", output = "latlng", 
        messaging = T)
state <- cbind(state, latlng)
# ascending order by latitude
stateOrder <- state[with(state, order(lat)), "state"]

### use animint to visualize CDC FluView data
library(animint)

# activity level heatmap
level.heatmap <- ggplot() + 
  geom_tile(data = state_flu, aes(x = WEEKEND, y = factor(STATENAME, level = stateOrder), 
                                   fill = level, clickSelects = WEEKEND)) + 
  geom_tallrect(aes(xmin = WEEKEND - 3, xmax = WEEKEND + 3, clickSelects = WEEKEND), 
                 data = state_flu, alpha = .5) + 
  scale_x_date(expand = c(0, 0)) + 
  scale_fill_gradient2(low = "white", high = "red", breaks = 0:10) + 
  ylab("STATENAME (Ascending Order of Latitude)") + 
  theme_animint(width = 1200, height = 700) + 
  ggtitle("CDC ILI Activity Level in Lower 48 States")

# state map
theme_opts <- list(theme(panel.grid.minor = element_blank(), 
                         panel.grid.major = element_blank(), 
                         panel.background = element_blank(), 
                         panel.border = element_blank(), 
                         plot.background = element_rect(fill = "#E6E8Ed"), 
                         axis.line = element_blank(), 
                         axis.text.x = element_blank(), 
                         axis.text.y = element_blank(), 
                         axis.ticks = element_blank(), 
                         axis.title.x = element_blank(), 
                         axis.title.y = element_blank()))

# USpolygons <- map_data("state")
# USpolygons$subregion <- NULL
# USpolygons <- subset(USpolygons, region != "district of columbia")
# USpolygons$STATENAME = state_flu$STATENAME[match(USpolygons$region, state_flu$state)]

# use US state polygons of coarse resolution to speed up
library(rgdal)
library(maptools)
library(plyr)

shape <- readOGR(dsn = "/Users/tonytsai/Documents/R/US/states", layer = "states")
shape@data$id = rownames(shape@data)
shape.polygons = fortify(shape, region = "id")
state = join(shape.polygons, shape@data, by = "id")
USpolygons <- subset(state[, c("long", "lat", "group", "order", "STATE_NAME")], 
                     !STATE_NAME %in% c("Alaska", "Hawaii", "District of Columbia"))
names(USpolygons)[5] <- "STATENAME"

# add state flu
map_flu <- ldply(unique(state_flu$WEEKEND), function(we) {
  df <- subset(state_flu, WEEKEND == we)
  df <- merge(USpolygons, df)
})

state.map <- ggplot() + 
  make_text(map_flu, -100, 50, "WEEKEND", "CDC FluView in Lower 48 States ending %s") + 
  geom_polygon(data = map_flu, aes(x = long, y = lat, group = group, fill = level, 
                                  showSelected = WEEKEND, clickSelects = STATENAME), 
                colour = "black", size = 1) + 
  scale_fill_gradient2(low = "white", high = "red", breaks = 0:10, guide = "none") + 
  theme_opts + 
  theme_animint(width = 750, height= 500)

ts.line <- ggplot() + 
  geom_line(data = state_flu, aes(x = WEEKEND, y = level, showSelected = STATENAME), 
             colour = "green") + 
  geom_point(data = state_flu, aes(x = WEEKEND, y = level, showSelected = STATENAME), 
             colour = "green") + 
  scale_y_continuous(limits = c(0, 11), breaks = 0:10, expand = c(0, 0)) + 
  make_text(state_flu, as.Date("2012-01-01"), y = 10.5, "STATENAME", 
             "ILI Activity Time Series of %s") + # make_text or geom_text can't annotate text out the limits
#    geom_text(data = state_flu, aes(x = as.Date("2012-01-01"), y = 11, 
#                                    showSelected = STATENAME, label = STATENAME)) + 
  ylab("LEVEL") + 
  theme_animint(width = 500, height = 500)

# state map can't be displayed smoothly when animated.
# viz <- list(levelHeatmap = level.heatmap, stateMap = state.map, tsLine = ts.line, 
#             time = list(variable = "WEEKEND", ms = 3000), 
#             duration = list(WEEKEND = 1000))
viz <- list(levelHeatmap = level.heatmap, stateMap = state.map, tsLine = ts.line, 
            title = "FluView")
system.time(animint2dir(viz, out.dir = "FluView"))
# system.time(animint2gist(viz, out.dir = "FluView"))
# Error: x$headers$`content-type` == "application/json; charset=utf-8" is not TRUE
