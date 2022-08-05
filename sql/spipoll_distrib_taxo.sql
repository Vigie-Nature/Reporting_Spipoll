	SELECT
		COUNT(insect.Ordre) as nb_observation,
		year(particip.`date`) as annee,
		insect.Ordre as insect_ordre
	FROM
		(spgp.spipoll_observation obs
	INNER JOIN spgp.spipoll_participation particip on
		obs.participationId = particip.id
	INNER JOIN spgp.spipoll_plante plant on
		particip.planteId = plant.id
	INNER JOIN spgp.spipoll_insecte insect on
		obs.taxonId = insect.id)				
		WHERE
		obs.nbValidation = 3 and (obs.nbSuggestIdent = 0 or obs.nbSuggestIdent IS NULL)
		GROUP BY annee, insect_ordre