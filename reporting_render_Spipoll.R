library(RMySQL)
library(lubridate)
library(sf)
library(raster)
library(dplyr)
library(spData)
library(spDataLarge)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2) # tidyverse data visualization package
library(rmarkdown)
library(knitr)




# DATA --------------------------------------------------------------------


# importation des fonctions de base à partir du fichier
source("fonctions/function_import_from_mosaic.R")
source("fonctions/function_encoding_utf8.R")
# export a plat Spipoll
query <- read_sql_query("sql/spipoll_export_a_plat.sql")

dt_spipoll <- import_from_mosaic(query, 
                                 database_name = "spgp",
                                 force_UTF8 = TRUE)%>%
  #conserver uniquement les données depuis 2010
  filter(year(collection_date) > 2009) %>%
  mutate(#colonne annee de la collection
         annee = year(collection_date),
         #colonne groupe taxonomique
         groupes = ifelse(insecte_ordre %in% c("Blattodea",
                                               "Dermaptera",
                                               "Mecoptera",
                                               "Neuroptera",
                                               "Opiliones",
                                               "Orthoptera",
                                               "Ephemeroptera",
                                               "Collembola",
                                               "Raphidioptera"), 
                          "Autres", 
                          NA))
dt_spipoll[which(dt_spipoll$insecte_ordre == "Diptera"),]$groupes <- "Diptères"
dt_spipoll[which(dt_spipoll$insecte_ordre == "Hymenoptera"),]$groupes <- "Hyménoptères"
dt_spipoll[which(dt_spipoll$insecte_ordre == "Coleoptera"),]$groupes <- "Coléoptères"
dt_spipoll[which(dt_spipoll$insecte_ordre == "Lepidoptera"),]$groupes <- "Lépidoptères"
dt_spipoll[which(dt_spipoll$insecte_ordre == "Hemiptera"),]$groupes <- "Hemiptères"
dt_spipoll[which(dt_spipoll$insecte_ordre == "Araneae"),]$groupes <- "Arachnides"

#remplacer les NAs par des zéros dans les champs 'protocole_long' et 'nb_validations'
dt_spipoll$protocole_long[is.na(dt_spipoll$protocole_long)] <- 0
dt_spipoll$nb_validation[is.na(dt_spipoll$nb_validation)] <- 0

#créer une colonne 'période" pour grouper les obs sur des périodes de 4 ans (à modifier dans l'argument breaks)
dt_spipoll <- dt_spipoll %>%
  mutate(periode = factor(cut(annee,
                       #Add 1 to the maximum value in dim to make sure it is included in the categorization.
                       breaks = c((seq(min(annee), max(annee), 4)), Inf),
                       #Set this to TRUE to include the lowest value
                       include.lowest = TRUE,
                       labels = FALSE,
                       #intervals are open on the right
                       right = FALSE)))



# FIGURES -----------------------------------------------------------------

## Variations mensuelles des observations par grands groupes taxonomiques
# résumé des interactions au groupe taxo ramenées au mois
taxo_mensuel <- dt_spipoll  %>%
  filter(nb_validation == 3, !is.na(insecte_ordre)) %>%
  mutate(mois = month(collection_date)) %>%
  group_by(mois, groupes) %>%
  summarise(nb_observations = n()) %>%
  mutate(percentage = nb_observations/sum(nb_observations)) %>%
  arrange(nb_observations) %>%
  mutate(groupes = factor(groupes, groupes))

## Variations mensuelles des observations par grands groupes taxonomiques

# palette de couleur du Spipoll, manuellement assignée aux 7 groupes
palette_spipoll <- c("Diptères" = "#FF3300",
                     "Hyménoptères" = "#B5F500",
                     "Coléoptères" = "#D5002A",
                     "Lépidoptères" = "#FFE800",
                     "Hemiptères" = "#006C80",
                     "Arachnides" = "#4D0059",
                     "Autres" = "#333333")


# Plot de la phénologie des grands groupes de visiteurs (lines & points)
le_plot_taxo_mensuel <- ggplot(taxo_mensuel, aes(x=mois, y=percentage, colour=groupes)) + 
  geom_line(size = 0.8)+
  geom_point(size = 1.5)+
  labs(title = "Groupes taxonomiques",
       y = "Proportion des observations totales",
       x = "Mois",
       colour = "Groupes") +
  scale_colour_manual(values = palette_spipoll) + 
  scale_x_continuous(
    breaks = seq_along(month.name), 
    labels = c("Janv", "Fev", "Mars", "Avril", "Mai", "Juin", "Juill", "Aout", "Sept", "Oct",  "Nov", "Dec"),
    expand = c(0, 0))+ 
  scale_y_continuous(labels = scales::percent,
                     expand = c(0, 0))+
  theme_bw() +
  theme(
    axis.text = element_text(size = 10),
    axis.title.x = element_blank(),
    title = element_text(size = 13),
    legend.background = element_rect(fill = "white", color = "black"),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10))


# CARTO -------------------------------------------------------------------

#carto des collections, et répartition des données Spipoll
# import fond de carte
carte_france = sf::read_sf("maps/metropole-version-simplifiee.geojson")
carte_regions = sf::read_sf("maps/regions-version-simplifiee.geojson")
carte_departements = sf::read_sf("maps/departements-version-simplifiee.geojson")


#liste contenant les differentes cartes
les_maps <- list()
#incrément pour liste de cartes
a=1
#Boucle pour afficher les cartes de distribution des collections en France suivant des périodes de 4 ans
for(i in unique(levels(dt_spipoll$periode)))
{
  #ajout du fond de carte de la France comme base
  la_carte <- tm_shape(carte_france) +
    tm_borders(lwd = 1, col = "grey") +
    #ajout couche departements
    tm_shape(carte_departements) + 
    tm_borders(lwd = 1, col = "grey") +
    tm_shape(carte_france) +
    tm_borders(lwd = 1, col = "black") +
    #ajout des points pour les collections du Spipoll sur la periode i
    tm_shape(sf::st_as_sf(na.omit(dt_spipoll %>% 
                                    filter(periode == i) %>%
                                    distinct(collection_id,
                                             latitude,
                                             longitude)),
                          coords = c("longitude", 
                                     "latitude"),
                          crs = 4326)) +
    tm_dots(col = "darkorchid4") +
    #ajout titre  
    tm_layout(title= paste(min(dt_spipoll$annee[dt_spipoll$periode == i]),
                           max(dt_spipoll$annee[dt_spipoll$periode == i]),
                           sep="-"), 
              title.position = c('left', 'bottom'))
  #on ajoute la nouvelle carte à la liste, en modifiant le type d'objet pour le grid.arrange ensuite qui permettra d'afficher simultanément plusieurs cartes
  les_maps[[a]] <- la_carte
  a=a+1
}






# RENDER ------------------------------------------------------------------




#render en html uniquement pour les participants avec 3 participations ou plus en protocole flash
users_3_collections <- dt_spipoll %>% 
  filter(protocole_long == 0) %>%
  group_by(user_pseudo) %>% 
  summarise(nb_collections = n_distinct(collection_id)) %>%
  filter(nb_collections >= 3) %>%
  pull(user_pseudo)


#boucle render
for(user in users_3_collections)
  {
  render("./reporting_template_Spipoll.Rmd",
         output_file=paste0("./reporting/reporting_", user, ".html"),
         params=list(new_title=paste("Restitution Spipoll -", user)))
  }






