-- Career high query from edges table

SELECT 
	v.properties->>'player_name',
	MAX(CAST(e.properties->>'pts' AS INTEGER))
FROM vertices v JOIN edges e
ON e.subject_identifier = v.identifier
AND e.subject_type = v.type
GROUP BY 1 
ORDER BY 2 DESC
