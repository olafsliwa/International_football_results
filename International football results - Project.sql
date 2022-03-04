--	Overview of data

SELECT *
FROM Project.dbo.results;

sp_help results;

SELECT *
FROM Project.dbo.results
WHERE 1 IS NULL OR 2 IS NULL OR 3 IS NULL
OR 4 IS NULL or 5 IS NULL OR 6 IS NULL
OR 7 IS NULL or 8 IS NULL OR 9 IS NULL;

ALTER TABLE Project.dbo.results
ADD correct_date date,
[Match-ID] int IDENTITY(1,1) PRIMARY KEY;

UPDATE Project.dbo.results
set correct_date = (CASE
	WHEN SUBSTRING(date,3,1) = '.' THEN SUBSTRING([date],7,4) + '-' + SUBSTRING([date],4,2) + '-' + SUBSTRING ([date],1,2)
	ELSE [date]
END);

ALTER TABLE Project.dbo.results
DROP COLUMN [date];


----------------------------------------------------
--	Average number of goals scored by each Team
--	(Conditions: number of total matches played by a team > 300)

WITH T_goals AS
(SELECT home_team as team, home_score as score, [Match-ID]
FROM Project.dbo.results
UNION ALL
SELECT away_team, away_score, [Match-ID]
FROM Project.dbo.results)

SELECT team, AVG(score) as average_goals
INTO results_average_goals
FROM T_goals
GROUP BY team
HAVING COUNT(team) > 300
ORDER BY average_goals DESC;

SELECT team, ROUND(average_goals, 2) AS average_goals
FROM Project.dbo.results_average_goals
ORDER BY average_goals DESC;


----------------------------------------------------
--	The percentage of wins by City
--	(Condition: number of matches played in a single city > 100. Competition that took place on neutral ground is not considered)

WITH matches_city AS
(SELECT city, COUNT(CASE WHEN home_score > away_score THEN 1 ELSE NULL END) AS matches_won, COUNT(city) AS total_matches
FROM Project.dbo.results
WHERE neutral = 'False'
GROUP BY city
HAVING COUNT(city) > 100)

SELECT city, CAST(ROUND(CAST(matches_won AS float)/CAST(total_matches AS float)*100, 2) AS varchar(50)) + '%' AS percentage_of_wins
FROM matches_city
ORDER BY percentage_of_wins DESC;


----------------------------------------------------
--	Average number of goals scored per City
--	(Condition: number of matches played in a single city > 100)

SELECT city, ROUND(SUM(home_score+away_score)/COUNT(city),2) AS average_of_goals_scored
FROM results
GROUP BY city
HAVING COUNT(city) > 100
ORDER BY average_of_goals_scored DESC;