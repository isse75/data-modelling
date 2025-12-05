WITH years as (
	SELECT * 
	FROM generate_series(1970, 2021) as year
),

--- identify first years
	first_years as (
		SELECT
			actorid,
			actor,
			MIN(year) as first_year
		FROM actor_films
		GROUP BY actorid, actor
),

-- get all years of acting from actor
	actors_and_years as (
		SELECT
			*
		FROM first_years fy
		JOIN years y
			ON fy.first_year <= y.year
		ORDER BY actorid, actor
),

-- get all "film" data arrays for each actor
	windowed as (
		SELECT
			ay.actorid,
			ay.actor,
			ay.year,
			ARRAY_REMOVE(ARRAY_AGG(CASE WHEN af.year IS NOT NULL THEN ROW(film, votes, rating,filmid)::films END) 
							OVER (PARTITION BY ay.actorid, ay.actor ORDER BY COALESCE(ay.year, af.year)), NULL) as films
		FROM actors_and_years ay
		LEFT JOIN actor_films af
		ON af.actorid = ay.actorid
		AND ay.year = af.year
),

-- info on actors' final year acting
	static as (
		SELECT
			actorid,
			MAX(actor) as actor,
			MAX(year) as current_year
		FROM actor_films
		GROUP BY actorid
),
-- Collate all data, include case when logic for quality class. rank based on year
	ranking as (
		SELECT
			s.actorid,
			w.actor,
			w.films,
			w.year,
			CASE
				WHEN (films[CARDINALITY(films)]::films).rating > 8 THEN 'star'
				WHEN (films[CARDINALITY(films)]::films).rating > 7 THEN 'good'
				WHEN (films[CARDINALITY(films)]::films).rating > 6 THEN 'average'
				ELSE 'bad'
			END as quality_class,
			s.current_year = w.year as is_active,
			ROW_NUMBER() OVER (PARTITION BY s.actorid ORDER BY w.year DESC) as rank
		FROM static s
		JOIN windowed w
			ON w.actorid = s.actorid
	)
	
-- final output
SELECT
	actorid,
	actor,
	films,
	quality_class,
	is_active
FROM ranking
WHERE rank = 1;


