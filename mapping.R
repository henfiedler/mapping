# load packages

packages <- c("readr", "tidyverse", "leaflet", "sf")

for (p in packages) {
  if (p %in% installed.packages()[,1]) {
    print(paste0(p, ' is installed. Will now load ', p,'.'))
    library(p, character.only=T)
  }
  else {
    print(paste0(p, ' is NOT installed. Will now install ', p,'.'))
    install.packages(p)
    library(p, character.only=T)
  }
}

rm(packages, p)

# load data

## German cities with lon/lat (source: https://simplemaps.com/data/de-cities)
de <- read_csv("data/de.csv")

## dataset with subscribers from mailchimp (only available for admin)
Mailchimp <- read_csv("data/Test.csv", col_names = FALSE)


# Preparation

## changing variable name for location to create a unique identifier
Mailchimp <- Mailchimp %>%
  rename(city = "In welcher Stadt lebst du? / In what city? *")

## matching Mailchimp-df and cities' location by "city"
df <- Mailchimp %>%
  left_join(de, by = "city")


## Converting data frame to sf-Format (geometry list)

df <- st_as_sf(df, coords = c("lng", "lat"), 
               crs = 4326, agr = "constant") # sind die Angaben über crs und agr überhaupt notwendig?

# Plotting with leaflet (clustering)

leaflet(df) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~as.character(city))