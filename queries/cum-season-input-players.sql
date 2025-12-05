INSERT INTO players
-- Get series of years
WITH years AS (
    SELECT *
    FROM GENERATE_SERIES(1996, 2022) AS season
),

-- Get first season from players
first_season as (
SELECT player_name,
	   MIN(season) as first_season
FROM player_seasons
GROUP BY player_name),

-- Get all seasons from first season of player

players_and_seasons as (
SELECT *
FROM first_season fs
JOIN years y ON
fs.first_season <= y.season
ORDER BY player_name),


-- Get all season stats for each player
windowed as (
SELECT pas.player_name,
pas.season,
ARRAY_REMOVE(ARRAY_AGG(	
				CASE WHEN ps.season IS NOT NULL THEN ROW(ps.season, ps.gp, ps.pts, ps.reb, ps.ast)::season_stats END)
				OVER (PARTITION BY pas.player_name ORDER BY pas.season), NULL) as seasons
				FROM players_and_seasons pas
LEFT JOIN player_seasons ps
ON pas.player_name = ps.player_name
AND pas.season = ps.season
ORDER BY pas.player_name, pas.season),

-- Get info on players' final season
static as (
SELECT 
	player_name,
	MAX(height) as height,
	MAX(college) as college,
	MAX(country) as country,
	MAX(draft_year) as draft_year,
	MAX(draft_round) as draft_round,
	MAX(draft_number) as draft_number,
	MAX(season) as season
FROM player_seasons
GROUP BY player_name),

ranked as (
SELECT w.player_name,
	   s.height,
	   s.college,
	   s.country,
	   s.draft_year,
	   s.draft_round,
	   s.draft_number,
	   seasons as season_stats,
	   CASE
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 20 THEN 'star'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 15 THEN 'good'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 10 THEN 'average'
        ELSE 'bad'
   		END::scoring_class AS scoring_class,
		w.season - (seasons[CARDINALITY(seasons)]::season_stats).season as years_since_last_active,
		w.season as current_season,
		(seasons[CARDINALITY(seasons)]::season_stats).season = w.season AS is_active,
		ROW_NUMBER() OVER (PARTITION BY w.player_name ORDER BY w.season DESC) AS rank
FROM static s
JOIN windowed w 
ON w.player_name = s.player_name)

SELECT
	player_name,
	height,
	college,
	country,
	draft_year,
	draft_round,
	draft_number,
	season_stats,
	scoring_class,
	years_since_last_active,
	current_season,
	is_active
FROM ranked
WHERE rank = 1

				
