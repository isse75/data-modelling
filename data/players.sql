-- CREATE DATAFRAME WITH PLAYERS CONTAINING ARRAY OF THEIR SEASON STATS AND CATEGORISING SCORING CLASS

 CREATE TYPE season_stats AS (
                         season Integer,
                         gp REAL,
                         pts REAL,
                         reb REAL,
                         ast INTEGER
                       );
 CREATE TYPE scoring_class AS
     ENUM ('bad', 'average', 'good', 'star');


 CREATE TABLE players (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     seasons season_stats[],
     scoring_class scoring_class,
     years_since_last_active INTEGER,
     is_active BOOLEAN,
     current_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );


INSERT INTO players
WITH yesterday AS (
SELECT * FROM players
WHERE current_season = 1995
),
today AS(
SELECT * FROM player_seasons
WHERE season = 1996
	)

SELECT COALESCE(t.player_name, y.player_name) as player_name,
COALESCE(t.height, y.height) as height,
COALESCE(t.college, y.college) as college,
COALESCE(t.country, y.country) as country,
COALESCE(t.draft_year, y.draft_year) as draft_year,
COALESCE(t.draft_round, y.draft_round) as draft_round,
COALESCE(t.draft_number, y.draft_number) as draft_number,
CASE WHEN y.season_stats IS NULL 
	THEN ARRAY[ROW(
t.season,
t.gp,
t.pts,
t.reb,
t.ast)
	::season_stats]
WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
t.season,
t.gp,
t.pts,
t.reb,
t.ast)
	::season_stats]
ELSE y.season_stats
END as season_stats,
COALESCE(t.season, y.current_season + 1) as current_season,
CASE 
	WHEN t.season IS NOT NULL THEN
		CASE WHEN t.pts > 20 THEN 'star'
			WHEN t.pts > 15 THEN 'good'
			WHEN t.pts > 10 THEN 'average'
			ELSE 'bad'
	END::scoring_class 
	ELSE y.scoring_class
END as scoring_class,
CASE 
	WHEN t.season IS NOT NULL THEN 0
	ELSE y.years_since_last_season + 1
		END as years_since_last_season
FROM today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;

