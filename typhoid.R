# Load necessary libraries
library(leaflet)
library(sf)
library(dplyr)
library(htmlwidgets)

# Generate sample data for typhoid cases in DRC
set.seed(123)  # For reproducibility
drc_patients <- data.frame(
  longitude = runif(100, min = 12.0, max = 31.0),  # Approximate longitude range for DRC
  latitude = runif(100, min = -13.5, max = 5.5),   # Approximate latitude range for DRC
  intensity = runif(100, min = 1, max = 10)  # Represents number of patients
)

# Convert to a spatial data frame
drc_patients_sf <- st_as_sf(drc_patients, coords = c("longitude", "latitude"), crs = 4326)

# Define a color palette function based on intensity
pal <- colorNumeric(palette = "YlOrRd", domain = drc_patients_sf$intensity)

# Create the leaflet map
drc_map <- leaflet(data = drc_patients_sf) %>%
  addTiles() %>%
  addCircleMarkers(
    radius = ~sqrt(intensity) * 3,  # Adjust the radius for better visualization
    color = ~pal(intensity),
    fillOpacity = 0.5,
    stroke = FALSE,
    label = ~paste("Expected Cases:", intensity)
  ) %>%
  addLegend(
    position = "topright",
    pal = pal,
    values = ~intensity,
    title = "Expected Typhoid Cases",
    opacity = 1,
    labFormat = labelFormat(
      prefix = "",
      suffix = " cases",
      between = " - ",
      transform = function(x) round(x)
    ),
    className = "info legend"
  )

# Customize the legend using HTML/CSS
css <- "
  .info.legend {
    background-color: rgba(255, 255, 255, 0.8);
    border-radius: 5px;
    padding: 10px;
    font-family: Arial, sans-serif;
    font-size: 12px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
  }
  .info.legend h4 {
    margin-top: 0;
    color: #444;
  }
"

# Add the CSS style to the map
drc_map <- htmlwidgets::onRender(drc_map, paste0("
  function(el, x) {
    var css = '", css, "';
    var style = document.createElement('style');
    style.type = 'text/css';
    style.appendChild(document.createTextNode(css));
    document.head.appendChild(style);
  }
"))

# Display the map
drc_map

# Save the map to an HTML file
saveWidget(drc_map, file = "drc_typhoid_heatmap.html", selfcontained = TRUE)
