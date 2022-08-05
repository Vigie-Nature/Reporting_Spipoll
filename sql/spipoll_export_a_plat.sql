select
    `p`.`id` AS `collection_id`,
    `p`.`name` AS `collection_nom`,
    `p`.`protocoleLong` AS `protocole_long`,
    `p`.`userId` AS `user_id`,
    `u`.`username` AS `user_pseudo`,
    `u`.`email` AS `user_email`,
    cast(replace(replace(replace(`p`.`commentaire`, '\\r', ' '), '\\n', ' '), '\\t', ' ') as char charset utf8mb3) AS `commentaire`,
    `plante`.`sc_name` AS `plante_sc`,
    `plante`.`fr_name` AS `plante_fr`,
    `plante`.`long_name` AS `plante_long_name`,
    `p`.`plantePrecision` AS `plante_precision`,
    `p`.`planteInconnue` AS `plante_inconnue`,
    `caractere_plante`.`value` AS `plante_caractere`,
    concat('https://spgp-api.65mo.fr', `mediaFleur`.`url`) AS `photo_fleur`,
    concat('https://spgp-api.65mo.fr', `mediaPlante`.`url`) AS `photo_plante`,
    concat('https://spgp-api.65mo.fr', `mediaFeuille`.`url`) AS `photo_feuille`,
    concat('https://spgp-api.65mo.fr', `mediaStation`.`url`) AS `photo_lieu`,
    st_y(`p`.`geopoint`) AS `latitude`,
    st_x(`p`.`geopoint`) AS `longitude`,
    `p`.`postalCode` AS `code_postal`,
    `hab`.`habitat` AS `habitat`,
    `p`.`distanceRuche` AS `distance_ruche`,
    `grande_culture`.`value` AS `grande_culture`,
    `p`.`date` AS `collection_date`,
    `p`.`heureDebut` AS `collection_heure_debut`,
    `p`.`heureFin` AS `collection_heure_fin`,
    `nebulosite`.`value` AS `nebulosite`,
    `temperature`.`value` AS `temperature`,
    `vent`.`value` AS `vent`,
    `p`.`fleurOmbre` AS `fleur_ombre`,
    `taxon`.`sc_name` AS `insecte_sc`,
    `taxon`.`fr_name` AS `insecte_fr`,
    `taxon`.`long_name` AS `insecte_long_name`,
    `taxon`.`RANG` AS `insecte_rang`,
    `taxon`.`Ordre` AS `insecte_ordre`,
    `o`.`taxonPrecision` AS `insecte_precision`,
    `abondance`.`value` AS `insecte_abondance`,
    concat('https://spgp-api.65mo.fr', `mediaTaxon1`.`url`) AS `insecte_photo_1`,
    concat('https://spgp-api.65mo.fr', `mediaTaxon2`.`url`) AS `insecte_photo_2`,
    `o`.`taxonVuSurFleur` AS `insecte_vu_sur_fleur`,
    `o`.`nbValidation` AS `nb_validation`,
    `o`.`nbSuggestIdent` AS `nb_suggestion`,
    `o`.`created` AS `date_creation_bdd`,
    `o`.`updated` AS `date_update_bdd`
from
    (((((((((((((((((`spgp`.`spipoll_participation` `p`
left join `spgp`.`users` `u` on
    (`u`.`id` = `p`.`userId`))
left join `spgp`.`spipoll_plante` `plante` on
    (`plante`.`id` = `p`.`planteId`))
left join `spgp`.`thesaurus` `caractere_plante` on
    (`caractere_plante`.`id` = `p`.`caractereFleurId`))
left join `spgp`.`medias` `mediaFleur` on
    (`mediaFleur`.`id` = `p`.`imgFleurId`))
left join `spgp`.`medias` `mediaPlante` on
    (`mediaPlante`.`id` = `p`.`imgPlanteId`))
left join `spgp`.`medias` `mediaFeuille` on
    (`mediaFeuille`.`id` = `p`.`imgFeuilleId`))
left join `spgp`.`medias` `mediaStation` on
    (`mediaStation`.`id` = `p`.`imgStationId`))
left join (
    select
        `spgp`.`spipoll_participation_habitat`.`participationId` AS `participationId`,
        group_concat(`spgp`.`thesaurus`.`value` separator ',') AS `habitat`
    from
        (`spgp`.`spipoll_participation_habitat`
    join `spgp`.`thesaurus` on
        (`spgp`.`spipoll_participation_habitat`.`habitatId` = `spgp`.`thesaurus`.`id`))
    group by
        `spgp`.`spipoll_participation_habitat`.`participationId`) `hab` on
    (`p`.`id` = `hab`.`participationId`))
left join `spgp`.`thesaurus` `grande_culture` on
    (`grande_culture`.`id` = `p`.`grandeCultureId`))
left join `spgp`.`thesaurus` `nebulosite` on
    (`nebulosite`.`id` = `p`.`nebulositeId`))
left join `spgp`.`thesaurus` `temperature` on
    (`temperature`.`id` = `p`.`temperatureId`))
left join `spgp`.`thesaurus` `vent` on
    (`vent`.`id` = `p`.`ventId`))
left join `spgp`.`spipoll_observation` `o` on
    (`o`.`participationId` = `p`.`id`))
left join `spgp`.`spipoll_insecte` `taxon` on
    (`taxon`.`id` = `o`.`taxonId`))
left join `spgp`.`thesaurus` `abondance` on
    (`abondance`.`id` = `o`.`nbTaxonId`))
left join `spgp`.`medias` `mediaTaxon1` on
    (`o`.`imgTaxon1Id` = `mediaTaxon1`.`id`))
left join `spgp`.`medias` `mediaTaxon2` on
    (`o`.`imgTaxon2Id` = `mediaTaxon2`.`id`))
where
    `p`.`isDeleted` = 0;
