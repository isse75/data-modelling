-- creating scd table that shows players' scoring_class journey
CREATE TABLE players_scd(
player_name TEXT,
scoring_class scoring_class,
is_active BOOLEAN,
start_season INTEGER,
end_season INTEGER,
current_season INTEGER,
PRIMARY KEY (player_name, start_season)
);

-- Create cte showing previous season scoring class and player active status
INSERT INTO players_scd
WITH with_previous as (
	SELECT 
	player_name,
	current_season,
	scoring_class,
	is_active,
	LAG(scoring_class, 1) OVER (PARTITION BY player_name ORDER BY current_season) as prev_scoring_class,
	LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) as prev_is_active
FROM players
WHERE current_season <= 2021),

-- create indicator cte highlighting when scoring class / active statuse changes
with_indicators as (
SELECT *,
	CASE 
		WHEN scoring_class <> prev_scoring_class THEN 1
		WHEN is_active <> prev_is_active THEN 1 
		ELSE 0 
	END as change_indicator
FROM with_previous),


-- identify streaks of scoring class and active status stays the same
with_streaks as (
SELECT *,
SUM(change_indicator) OVER (PARTITION BY player_name ORDER BY current_season) as streak_identifier
FROM with_indicators)


SELECT 
	player_name,
	scoring_class,
	is_active,
	MIN(current_season) as start_season,
	MAX(current_season) as end_season,
	2021 as current_season
FROM with_streaks
GROUP BY player_name, streak_identifier, is_active, scoring_class
ORDER BY player_name, streak_identifier





