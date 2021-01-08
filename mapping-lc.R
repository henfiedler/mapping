# load packages
library(tidyverse)
library(CoordinateCleaner)
library(readr)
library(rvest)
library(sf)
library(leaflet)

## Load geo data
# centroids of countries from package "CoordinateCleaner"
countries <- countryref %>% 
  filter(name == "Netherlands" | name == "Switzerland") %>%
  distinct(name, .keep_all = TRUE) %>%
  rename(lat = centroid.lat) %>% 
  rename(lng = centroid.lon) %>% 
  select(name, lat, lng, iso2)

# centroids of regions (manualy)
regions <- tibble(name = c("Ruhrgebiet", "Rhein-Main"),
                  lat = c(51.5, 50.1),
                  lng = c(7.5, 8.7),
                  iso2 = c("DE", "DE"))
# source: Ruhrgebiet: https://geohack.toolforge.org/geohack.php?pagename=Ruhr&params=51_30_N_7_30_E_region:DE_type:city
#         Rhein-Main: https://geohack.toolforge.org/geohack.php?pagename=Frankfurt_Rhine-Main&params=50.1_N_8.7_E_scale:1000000_region:DE

# international cities with lon/lat (source: https://simplemaps.com/data/de-cities)
cities <- read_csv("worldcities.csv") %>% # internationale Buchstabierung
  filter(iso2 == "DE" | iso2 == "FR" |  iso2 == "NL" |  iso2 == "CH") %>%
  rename(name = city) %>% 
  select(name, lat, lng, iso2)

# binding to one dataframe
geo <- rbind(countries, regions, cities)

## crawling lc-chapters from CorrelAid-Website with package rvest
# correlaid website
correlaid <- read_html(
  "https://correlaid.org/"
)

# lc-names
names <- correlaid %>%
  html_nodes("a.nav-item.nav-link.active") %>% 
  html_text()

# data frame
lc <- tibble(name = names) %>% 
  filter(!grepl("\\n", name)) %>% 
  distinct()

## joining data for mapping
# matching lc-names and city-names
df <- left_join(lc, geo, by = "name") %>%
  select(name, lat, lng)

# filter out rows with missing lat / long
df_sub <- df %>%
  filter(!is.na(lat) & !is.na(lng))
# difficulty with local chapters like "Ruhrgebiet" or Rhine-Main"

## Converting data frame to sf-Format (geometry list) with package sf
df_aggr <- st_as_sf(df_sub, coords = c("lng", "lat"))

## Creating interactive map with package leaflet
# creating a custom icon
correlaidxicon <- makeIcon(
  iconUrl = "https://gblobscdn.gitbook.com/spaces%2F-MMQj6Rqry0D6V-FfMJP%2Favatar-1605792600232.png",
  iconWidth = 30, iconHeight = 30,
  iconAnchorX = 30, iconAnchorY = 30
)
# source: https://stackoverflow.com/questions/31541077/custom-markers-in-leaflet/31746476

# Plotting with leaflet (clustering)
leaflet(df_aggr) %>%
  addTiles() %>%
  addMarkers(icon = correlaidxicon,
             label = ~as.character(name))
