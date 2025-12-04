-- adding to edges table

-- Adding plays_in data into edges table
INSERT INTO edges
WITH deduped as (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY player_id, game_id) as row_num
FROM game_details
)
SELECT
	player_id as subject_identifier,
	'player'::vertex_type as subject_type,
	game_id as object_identifier,
	'game'::vertex_type as object_type,
	'plays_in'::edge_type as edge_type,
	json_build_object(
		'start_position', start_position,
		'pts', pts,
		'team_id', team_id,
		'team_abbreviation', team_abbreviation
	) as properties
FROM deduped
WHERE row_num=1;

-- adding shares_team and plays_against into edge table 
INSERT INTO edges
WITH deduped AS (
    SELECT *, row_number() over (PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
     filtered AS (
         SELECT * FROM deduped
         WHERE row_num = 1
     ),
	aggregated as (
  SELECT
   f1.player_id as subject_player_id,
   MAX(f1.player_name) as subject_player_name,
   f2.player_id as object_player_id,
   MAX(f2.player_name) as object_player_name,
   CASE WHEN f1.team_abbreviation =         f2.team_abbreviation
		THEN 'shares_team'::edge_type
	ELSE 'plays_against'::edge_type
	END as edge_type,
	COUNT(1) AS num_games,
	SUM(f1.pts) AS subject_points,
	SUM(f2.pts) as object_points
FROM filtered f1
	JOIN filtered f2
	ON f1.game_id = f2.game_id
	AND f1.player_name <> f2.player_name
WHERE f1.player_id > f2.player_id
GROUP BY
   f1.player_id,
   f2.player_id,
   CASE WHEN f1.team_abbreviation =         f2.team_abbreviation
		THEN  'shares_team'::edge_type
	ELSE 'plays_against'::edge_type
	END)

SELECT 
	subject_player_id as subject_identifier,
	'player'::vertex_type AS subject_type,
	object_player_id as object_identifier,
	'player'::vertex_type AS object_type,
	edge_type as edge_type,
	json_build_object(
		'num_games', num_games,
		'subject_points', subject_points,
		'object_points', object_points
	)
FROM aggregated

