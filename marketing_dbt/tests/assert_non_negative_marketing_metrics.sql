
SELECT
    marketing_performance_key,
    platform,
    spend,
    impressions,
    clicks
FROM {{ ref('fct_marketing_performance') }}

WHERE
    spend < 0
    OR impressions < 0
    OR clicks < 0
