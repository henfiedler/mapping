# load packages
library(readr)
library(tidyverse)
library(leaflet)
library(sf)
library(snakecase)
# load data

## German cities with lon/lat (source: https://simplemaps.com/data/de-cities)

ca <- read_csv("data/subscribed_members_export_de459417e6.csv")
colnames(ca) <- snakecase::to_snake_case(colnames(ca))

colnames(ca)

# filter out rows with missing lat / long
ca_sub <- ca %>% 
  rename(city = in_welcher_stadt_lebst_du_in_what_city) %>% 
  mutate(longitude = as.numeric(longitude),
         latitude = as.numeric(latitude)) %>% 
  filter(!is.na(longitude) & !is.na(latitude))

## Converting data frame to sf-Format (geometry list)
ca_aggr <- st_as_sf(ca_sub, coords = c("longitude", "latitude"))

# Plotting with leaflet (clustering)
leaflet(ca_aggr) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~as.character(city))
