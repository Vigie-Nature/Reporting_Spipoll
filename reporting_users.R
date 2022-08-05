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


#liste des pseudos uniques des participants du spipoll
list_users <- data.table::fread("./reporting/rencontres_2022/users_rencontres_2022.txt", 
                                  sep = "\t",
                                  header = FALSE,
                                  encoding = "UTF-8")[,V1]


#render en html
for(user in list_users){
  #condition 1 : suffisamment de collections (au moins 3 ?)
  if (n_distinct(dt_spipoll %>% filter(user_pseudo == user) %>%
      select(collection_id)) > 2)
    {
    render("./reporting_user_template.Rmd",
           output_file=paste0("./reporting/reporting_", user, ".html"),
           params=list(new_title=paste("Restitution Spipoll -", user)))
    }
}


#render en pdf
for(v in list_users){
  #condition 1 : suffisamment de collections (au moins 3 ?)
  if (n_distinct(dt_spipoll %>% filter(user_pseudo == user) %>%
                 select(collection_id)) > 2)
  {
    render("./reporting_user_template.Rmd",
           output_file=paste0("./reporting/reporting_", user, ".pdf"),
           params=list(new_title=paste("Restitution Spipoll -", user)))
  }
}
