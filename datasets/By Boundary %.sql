WITH boundary_stats AS (
    SELECT
        fbs.batsmanName,
        dms.matchyear,
        SUM(fbs.Fours * 4 + fbs.Sixes * 6) AS boundary_runs, -- Total boundary runs
        SUM(fbs.runs) AS total_runs, -- Total runs scored
        SUM(fbs.balls) AS total_balls
    FROM
        fact_bating_summary fbs
    INNER JOIN
        dim_match_summary dms ON fbs.match_id = dms.match_id
    WHERE
        dms.matchyear BETWEEN 2021 AND 2023
    GROUP BY
        fbs.batsmanName,
        dms.matchyear
),
yearly_ball_counts AS (
    SELECT
        batsmanName,
        SUM(CASE WHEN matchyear = 2021 THEN total_balls END) AS balls_2021,
        SUM(CASE WHEN matchyear = 2022 THEN total_balls END) AS balls_2022,
        SUM(CASE WHEN matchyear = 2023 THEN total_balls END) AS balls_2023
    FROM
        boundary_stats
    GROUP BY
        batsmanName
),
qualified_batsmen AS (
    SELECT
        batsmanName
    FROM
        yearly_ball_counts
    WHERE
        balls_2021 >= 60 AND balls_2022 >= 60 AND balls_2023 >= 60
),
boundary_percentage AS (
    SELECT
        bs.batsmanName,
        SUM(bs.boundary_runs) AS boundary_runs,
        SUM(bs.total_runs) AS total_runs,
        ROUND((SUM(bs.boundary_runs) / SUM(bs.total_runs) * 100), 2) AS boundary_percent -- Calculating boundary percentage
    FROM
        boundary_stats bs
    INNER JOIN
        qualified_batsmen qb ON bs.batsmanName = qb.batsmanName
    GROUP BY
        bs.batsmanName
)
SELECT
    batsmanName,
    boundary_runs,
    total_runs,
    boundary_percent
FROM
    boundary_percentage
ORDER BY
    boundary_percent DESC
LIMIT 5;



