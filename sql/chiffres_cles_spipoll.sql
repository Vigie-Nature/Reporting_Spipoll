SELECT
    'nb_total_collections' as titre,
    COUNT(*)
 as nb
FROM
    spgp.spipoll_participation
UNION
SELECT
    'nb_collections_en_2021',
    COUNT(*)
FROM
    spgp.spipoll_participation
WHERE
    LEFT(date,
    4) > 2020
UNION
SELECT
    'nb_collections_faites_sur_smartphone',
    COUNT(*)
FROM
    spgp.spipoll_participation
WHERE
    spgp.spipoll_participation.shotOnPhone is true
union
SELECT
    'nb_collections_paramétrées_avec_lapp_mais photos_prises_avec_appareil_photo',
    count(*)
FROM
    spgp.spipoll_participation
WHERE
    JSON_EXTRACT(source,
    '$.origin') = 'app' and shotOnPhone = 0
UNION
SELECT
    'nb_participants_depuis_le_debut',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT userid
    FROM
        spgp.spipoll_participation) AS sr
UNION
SELECT
    'nb_participants_en_2021',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT userid
    FROM
        spgp.spipoll_participation
    where
        year(date)= 2021) AS sr
UNION
SELECT
    'nb_participants_utilisant_smartphone_depuis_le_debut',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT userid
    FROM
        spgp.spipoll_participation
    where
        spgp.spipoll_participation.shotOnPhone is true ) AS sr
UNION
SELECT
    'nb_participants_utilisant_smartphone_en_2021',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT userid
    FROM
        spgp.spipoll_participation
    where
        spgp.spipoll_participation.shotOnPhone is true
        and year(date)= 2021) AS sr
UNION
SELECT
    'total_mn_obs',
    (COUNT(*) * 20) + 1193040
FROM
    spgp.spipoll_participation
where
    year(date)>2018
UNION
SELECT
    'total_mn_obs_depuis_debut_2021',
    COUNT(*) * 20
FROM
    spgp.spipoll_participation
WHERE
    LEFT(date,
    4) > 2020
UNION
SELECT
    'nb_collections_en_2021',
    COUNT(*)
FROM
    spgp.spipoll_participation
WHERE
    LEFT(date,
    4) > 2020
UNION
SELECT
    'nb_total_photos',
    (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation) + (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    WHERE
        imgTaxon2id IS NOT NULL)
UNION
SELECT
    'nb_photos_depuis_debut_2021',
    (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        LEFT(spgp.spipoll_participation.date,
        4) > 2020) + (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        imgTaxon2id IS NOT NULL
        AND LEFT(spgp.spipoll_participation.date,
        4) > 2020)
UNION
SELECT
    'nb_insectes_avec_2_photos',
    (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        imgTaxon2id IS NOT NULL)
UNION
SELECT
    'total_insect_(1_3_10)_depuis _debut_2021',
    (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        nbTaxonId = 207
        AND LEFT(spgp.spipoll_participation.date,
        4) > 2020) + (
    SELECT
        COUNT(*) * 3
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        nbTaxonId = 208
        AND LEFT(spgp.spipoll_participation.date,
        4) > 2020) + (
    SELECT
        COUNT(*) * 10
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    WHERE
        nbTaxonId = 210
        AND LEFT(spgp.spipoll_participation.date,
        4) > 2020)
UNION
SELECT
    'total_insect_(1_3_10)',
    (
    SELECT
        COUNT(*)
    FROM
        spgp.spipoll_observation
    WHERE
        nbTaxonId = 207) + (
    SELECT
        COUNT(*) * 3
    FROM
        spgp.spipoll_observation
    WHERE
        nbTaxonId = 208) + (
    SELECT
        COUNT(*) * 10
    FROM
        spgp.spipoll_observation
    WHERE
        nbTaxonId = 210) + 759645
UNION
select
    'nb_moyen_dinsectes_diff_par_collection',
    avg(ric)
from
    (
    SELECT
        spgp.spipoll_participation.id,
        COUNT(*) as ric
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation
ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    group by
        spgp.spipoll_participation.id) t
UNION
select
    'nb_moyen_dinsectes_diff_par_collection_avec app_photo',
    avg(ric)
from
    (
    SELECT
        spgp.spipoll_participation.id,
        COUNT(*) as ric
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation
ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    where
        spgp.spipoll_participation.shotOnPhone is false
    group by
        spgp.spipoll_participation.id) t
UNION
select
    'nb_moyen_dinsectes_diff_par_collection_avec_smartphone',
    avg(ric)
from
    (
    SELECT
        spgp.spipoll_participation.id,
        COUNT(*) as ric
    FROM
        spgp.spipoll_observation
    INNER JOIN spgp.spipoll_participation
ON
        spgp.spipoll_observation.participationId = spgp.spipoll_participation.id
    where
        spgp.spipoll_participation.shotOnPhone is true
    group by
        spgp.spipoll_participation.id) t
UNION
SELECT
    'nb_taxons_plantes',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT planteid
    FROM
        spgp.spipoll_participation) AS sr
UNION
SELECT
    'nb_taxons_plantes',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT planteid
    FROM
        spgp.spipoll_participation) AS sr
UNION
SELECT
    'nb_taxon_insect',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT taxonId
    FROM
        spgp.spipoll_observation) AS sr
UNION
SELECT
    'nb_taxons_validés',
    COUNT(*)
FROM
    spgp.spipoll_observation
WHERE
    nbValidation = 3
UNION
SELECT
    'nb_taxons_avec_2_validations',
    COUNT(*)
FROM
    spgp.spipoll_observation
WHERE
    nbValidation = 2
UNION
SELECT
    'nb_taxons_avec_1_validation',
    COUNT(*)
FROM
    spgp.spipoll_observation
WHERE
    nbValidation = 1
UNION
SELECT
    'nb_taxons_non_validés',
    COUNT(*)
FROM
    spgp.spipoll_observation
WHERE
    nbValidation < 1
    OR nbValidation IS NULL
UNION
SELECT
    'nb_valideurs',
    COUNT(*)
FROM
    (
    SELECT
        DISTINCT spipoll_social_events.userId
    FROM
        spipoll_social_events) AS sr
UNION
SELECT
    'nb_moyen_validation',
    AVG(nbval)
FROM
    (
    SELECT
        userid,
        COUNT(*) AS nbval
    FROM
        spipoll_social_events
    GROUP BY
        userid) AS sr
UNION
SELECT
    'nb_commentaires',
    COUNT(*)
FROM
    spipoll_social_events
WHERE
    typeid = 4
UNION
SELECT
    'nb_commentaires_lus',
    COUNT(*)
FROM
    spipoll_social_events
WHERE
    typeid = 4
    AND isRead = 1
UNION
SELECT
    *
FROM
    (
    SELECT
        CONCAT('nb_validations ', users.username),
        COUNT(*) AS nbval
    FROM
        spipoll_social_events
    INNER JOIN spgp.users ON
        spipoll_social_events.userid = spgp.users.id
    GROUP BY
        username
    HAVING
        COUNT(*) > 20000
    ORDER BY
        COUNT(*) DESC) AS sr