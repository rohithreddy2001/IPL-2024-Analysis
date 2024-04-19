WITH yearly_stats AS (
    SELECT
        fs.batsmanName,
        dm.matchyear,
        SUM(fs.runs) AS total_runs,
        SUM(fs.balls) AS total_balls
    FROM
        fact_bating_summary fs
    JOIN
        dim_match_summary dm ON fs.match_id = dm.match_id
    WHERE
        dm.matchyear BETWEEN 2021 AND 2023
    GROUP BY
        fs.batsmanName,
        dm.matchyear
),
yearly_ball_counts AS (
    SELECT
        batsmanName,
        SUM(CASE WHEN matchyear = 2021 THEN total_balls END) AS balls_2021,
        SUM(CASE WHEN matchyear = 2022 THEN total_balls END) AS balls_2022,
        SUM(CASE WHEN matchyear = 2023 THEN total_balls END) AS balls_2023
    FROM
        yearly_stats
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
overall_stats AS (
    SELECT
        fs.batsmanName,
        SUM(fs.runs) AS overall_runs,
        sum(fs.dismissal) AS overall_outs 
    FROM
        fact_bating_summary fs
    JOIN
        dim_match_summary dm ON fs.match_id = dm.match_id
    WHERE
        dm.matchyear BETWEEN 2021 AND 2023
        AND fs.batsmanName IN (SELECT batsmanName FROM qualified_batsmen)
    GROUP BY
        fs.batsmanName
),
final_stats AS (
    SELECT
        os.batsmanName,
        os.overall_runs,
        os.overall_outs,
        round((os.overall_runs / os.overall_outs),2) AS batting_average
    FROM
        overall_stats os
)
SELECT
    batsmanName,
    overall_runs,
    overall_outs,
    batting_average
FROM
    final_stats
ORDER BY
    batting_average DESC
LIMIT 10;