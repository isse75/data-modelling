-- Identify player with biggest scoring jump between their first and last seasons
 SELECT player_name,
        (seasons[cardinality(seasons)]::season_stats).pts/
         CASE WHEN (seasons[1]::season_stats).pts = 0 THEN 1
             ELSE  (seasons[1]::season_stats).pts END
            AS ratio_most_recent_to_first
 FROM players
 WHERE current_season = 2001;


-- Retrieve the full career stat line for the highest scoring player in his latest season
WITH unnested AS (
SELECT player_name,
UNNEST(season_stats) as season_stats
FROM players
)

SELECT
player_name,
(season_stats[CARDINALITY(season_stats)]::season_stats).* 
FROM players
WHERE season_stats IS NOT NULL
  AND CARDINALITY(season_stats) > 0
ORDER BY pts DESC
LIMIT 1;

-- List Players Who Improved Their Points Every Season 

WITH unnested AS (
    SELECT 
        player_name,
        UNNEST(season_stats) AS season_stats
    FROM players
    WHERE current_season = 2001
),
pts_comparison AS (
    SELECT 
        player_name,
        (season_stats).season AS season,
        (season_stats).pts    AS pts,
        LAG((season_stats).pts, 1) OVER (
            PARTITION BY player_name
            ORDER BY (season_stats).season
        ) AS last_season_pts
    FROM unnested
)
SELECT DISTINCT player_name
FROM pts_comparison
WHERE player_name NOT IN (
    SELECT player_name
    FROM pts_comparison
    WHERE last_season_pts >= pts  
);


-- Compute per player career averages using only the array

WITH unnested AS (
    SELECT 
        player_name,
        UNNEST(season_stats) AS season_stats
    FROM players
    WHERE current_season = 2001
)

SELECT distinct player_name, 
(season_stats).pts,
(season_stats).gp,
SUM((season_stats).pts * (season_stats).gp)
   OVER (PARTITION BY player_name)
/
SUM((season_stats).gp)
   OVER (PARTITION BY player_name)
FROM unnested

