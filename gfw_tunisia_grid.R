library(leaflet)
library(lubridate)
library(dplyr)
library(htmlwidgets)
library(sf)
library(readr)  # For reading CSV files
setwd("/srv/shiny-server/comanage/")
# Read the port positions from the provided CSV file
tunisian_cities <- read_csv("./www/port_positions.csv")
gfw_rt <- read_csv("./www/gfw_data.csv")  # Adjust path as needed
# Set the bounding box for the Mediterranean Sea
med_bbox <- list(
  west = 7.26,
  east = 16.15,
  north = 40.45,
  south = 32
)
# Filter and process the fishing activity data
gfw_rt <- gfw_rt %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  mutate(time_range = as.Date(time_range))

# Define the grid size
grid_size <- 0.25

# Create the grid
grid <- st_make_grid(
  st_bbox(c(
    xmin = med_bbox$west, ymin = med_bbox$south,
    xmax = med_bbox$east, ymax = med_bbox$north
  )),
  cellsize = c(grid_size, grid_size),
  what = "polygons"
)

# Convert the grid to an sf object and set the CRS to WGS 84
grid_sf <- st_sf(geometry = grid)
st_crs(grid_sf) <- 4326

# Convert the fishing activity data to an sf object and set the CRS to WGS 84
gfw_sf <- st_as_sf(gfw_rt, coords = c("longitude", "latitude"), crs = 4326, agr = "constant")

# Assign fishing activity to grid cells
gfw_grid <- st_join(st_sf(geometry = grid_sf), gfw_sf, join = st_intersects)

# Summarize fishing effort by grid cell
grid_summary <- gfw_grid %>%
  group_by(geometry) %>%
  summarise(
    total_effort = sum(apparent_fishing_hours, na.rm = TRUE),
    top_flag = ifelse(length(table(flag)) > 0, names(which.max(table(flag))), "None"),
    top_gear = ifelse(length(table(gear)) > 0, names(which.max(table(gear))), "None")
  ) %>%
  filter(total_effort > 0)  # Keep only cells with fishing effort

# Apply log transformation to total_effort
grid_summary <- grid_summary %>%
  mutate(log_total_effort = log1p(total_effort))  # log1p is log(1 + x) to handle log(0)
# print(grid_summary$log_total_effort)

# Create a color palette for the grid
effort_pal <- colorNumeric(palette = "YlOrRd", domain = grid_summary$log_total_effort)

# Assuming gfw_rt$time_range is a character vector of date ranges
time_range_min <- min(as.Date(gfw_rt$time_range, format = "%Y-%m-%d"), na.rm = TRUE)
time_range_max <- max(as.Date(gfw_rt$time_range, format = "%Y-%m-%d"), na.rm = TRUE)

# eez <- st_read("./www/eez/eez.shp")

custom_icon <- makeIcon(
  iconUrl = "https://sp2.cs.vt.edu/shiny/comanage/port.png",
  iconWidth = 20, iconHeight = 20
)

# Create the leaflet map
m <- leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = grid_summary,
    fillColor = ~effort_pal(log_total_effort),
    fillOpacity = 0.75,
    color = "white",
    weight = 1,
    popup = ~paste(
      "Total Effort (hours):", total_effort, "<br>",
      "Top Flag:", top_flag, "<br>",
      "Top Gear:", top_gear
    )
  ) %>%
  addControl(html = paste0(
    "<div style='background: white; padding: 5px; font-size: 16px; font-weight: bold;'>",
    "Dates: ", time_range_min, " to ", time_range_max,
    "</div>"
  ), position = "topright") %>%
  addMarkers(
    data = tunisian_cities,
    lat = ~latitude,
    lng = ~longitude,
    popup = ~port,
    icon = custom_icon
  ) %>%
  addLegend(
    position = "bottomright",
    pal = effort_pal,
    values = grid_summary$log_total_effort,
    title = "Total Effort (hours)",
    opacity = 0.7,
    labFormat = labelFormat(transform = function(x) round(expm1(x)))  # Convert log scale back to original scale for labels
  ) %>%
  setView(lng = 10.5, lat = 36.5, zoom = 7)  # Set the initial zoom level and center

# Save the map
saveWidget(m, "./www/fishing_effort_grid.html", selfcontained = FALSE)
