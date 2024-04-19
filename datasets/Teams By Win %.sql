WITH team_wins AS (
    SELECT
        team,
        matchyear,
        COUNT(*) AS wins
    FROM
        (SELECT team1 AS team, matchyear FROM dim_match_summary WHERE winner = team1 AND matchyear BETWEEN 2021 AND 2023
         UNION ALL
         SELECT team2 AS team, matchyear FROM dim_match_summary WHERE winner = team2 AND matchyear BETWEEN 2021 AND 2023) AS winners
    GROUP BY
        team, matchyear
),
team_matches AS (
    SELECT
        team,
        matchyear,
        COUNT(*) AS matches
    FROM
        (SELECT team1 AS team, matchyear FROM dim_match_summary WHERE matchyear BETWEEN 2021 AND 2023
         UNION ALL
         SELECT team2 AS team, matchyear FROM dim_match_summary WHERE matchyear BETWEEN 2021 AND 2023) AS matches
    GROUP BY
        team, matchyear
),
combined_stats AS (
    SELECT
        COALESCE(w.team, m.team) AS team,
        COALESCE(w.matchyear, m.matchyear) AS matchyear,
        COALESCE(w.wins, 0) AS wins,
        COALESCE(m.matches, 0) AS matches
    FROM
        team_wins w
    LEFT JOIN
        team_matches m ON w.team = m.team AND w.matchyear = m.matchyear
    UNION
    SELECT
        COALESCE(m.team, w.team) AS team,
        COALESCE(m.matchyear, w.matchyear) AS matchyear,
        COALESCE(w.wins, 0) AS wins,
        COALESCE(m.matches, 0) AS matches
    FROM
        team_matches m
    LEFT JOIN
        team_wins w ON m.team = w.team AND m.matchyear = w.matchyear
)
SELECT
    team,
    SUM(wins) AS total_wins,
    SUM(matches) AS total_matches,
    ROUND((SUM(wins) / NULLIF(SUM(matches), 0)) * 100, 2) AS winning_percentage
FROM
    combined_stats
GROUP BY
    team
ORDER BY
    winning_percentage DESC
LIMIT 10;
