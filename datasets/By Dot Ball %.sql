WITH yearly_performance AS (
    SELECT
        dms.matchyear,
        fbs.bowlerName,
        SUM(fbs.Zeros) AS total_dot_balls,
        SUM(fbs.balls) AS total_balls
    FROM
        fact_bowling_summary fbs
    JOIN
        dim_match_summary dms ON fbs.match_id = dms.match_id
    WHERE
        dms.matchyear BETWEEN 2021 AND 2023
    GROUP BY
        dms.matchyear, fbs.bowlerName
),
yearly_balls_bowled AS (
    SELECT
        bowlerName,
        SUM(CASE WHEN matchyear = 2021 THEN total_balls END) AS balls_bowled_2021,
        SUM(CASE WHEN matchyear = 2022 THEN total_balls END) AS balls_bowled_2022,
        SUM(CASE WHEN matchyear = 2023 THEN total_balls END) AS balls_bowled_2023
    FROM
        yearly_performance
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
bowlers_active_all_years AS (
    SELECT
        bowlerName
    FROM
        qualified_bowlers
    GROUP BY
        bowlerName
),
overall_performance AS (
    SELECT
        yp.bowlerName,
        SUM(yp.total_dot_balls) AS total_dot_balls,
        SUM(yp.total_balls) AS total_balls
    FROM
        yearly_performance yp
    WHERE
        yp.bowlerName IN (SELECT bowlerName FROM bowlers_active_all_years)
    GROUP BY
        yp.bowlerName
),
dot_ball_percentage AS (
    SELECT
        op.bowlerName,
        op.total_dot_balls,
        op.total_balls,
        round((op.total_dot_balls / op.total_balls)* 100,2) AS dotball_percent
    FROM
        overall_performance op
)
SELECT
    dbp.bowlerName,
    dbp.total_dot_balls,
    dbp.total_balls,
    dbp.dotball_percent
FROM
    dot_ball_percentage dbp
ORDER BY
    dbp.dotball_percent DESC
LIMIT 5;


select * from fact_bowling_summary where bowlerName = "JoshHazlewood";