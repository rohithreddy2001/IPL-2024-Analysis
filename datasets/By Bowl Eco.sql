WITH yearly_stats AS (
    SELECT
        fbs.bowlerName,
        dm.matchyear,
        SUM(fbs.runs) AS total_runs_conceded,
        SUM(fbs.balls) AS total_balls_bowled
    FROM
        fact_bowling_summary fbs
    JOIN
        dim_match_summary dm ON fbs.match_id = dm.match_id
    WHERE
        dm.matchyear BETWEEN 2021 AND 2023
    GROUP BY
        fbs.bowlerName,
        dm.matchyear
),
yearly_balls_bowled AS (
    SELECT
        bowlerName,
        SUM(CASE WHEN matchyear = 2021 THEN total_balls_bowled END) AS balls_bowled_2021,
        SUM(CASE WHEN matchyear = 2022 THEN total_balls_bowled END) AS balls_bowled_2022,
        SUM(CASE WHEN matchyear = 2023 THEN total_balls_bowled END) AS balls_bowled_2023
    FROM
        yearly_stats
    GROUP BY
        bowlerName
),
qualified_bowlers AS (
    SELECT
        bowlerName
    FROM
        yearly_balls_bowled
    WHERE
        balls_bowled_2021 >= 60 AND balls_bowled_2022 >= 60 AND balls_bowled_2023 >= 60
),
overall_stats AS (
    SELECT
        fbs.bowlerName,
        SUM(fbs.runs) AS overall_runs_conceded,
        SUM(fbs.balls) AS overall_balls_bowled
    FROM
        fact_bowling_summary fbs
    JOIN
        dim_match_summary dm ON fbs.match_id = dm.match_id
    WHERE
        dm.matchyear BETWEEN 2021 AND 2023
        AND fbs.bowlerName IN (SELECT bowlerName FROM qualified_bowlers)
    GROUP BY
        fbs.bowlerName
),
final_stats AS (
    SELECT
        os.bowlerName,
        os.overall_runs_conceded,
        os.overall_balls_bowled,
        round(SUM(os.overall_runs_conceded) / SUM(os.overall_balls_bowled/6),2) AS economy_rate
    FROM
        overall_stats os
	group by 
        os.bowlerName
)
SELECT
    bowlerName,
    overall_runs_conceded,
    overall_balls_bowled,
    round(sum(overall_balls_bowled/6)) as overs_bowled,
    economy_rate    
FROM
    final_stats
group by
    bowlerName
ORDER BY
    economy_rate ASC
LIMIT 10;