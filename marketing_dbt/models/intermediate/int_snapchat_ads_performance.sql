
WITH stats AS (
    SELECT *
    FROM {{ ref('stg_snapchat_ads_stats') }}
),

ads AS (
    SELECT *
    FROM {{ ref('stg_snapchat_ads') }}
),

adgroups AS (
    SELECT *
    FROM {{ ref('int_snapchat_latest_adgroups') }}
),

campaigns AS (
    SELECT *
    FROM {{ ref('stg_snapchat_campaigns') }}
),

final AS (
    SELECT
        'snapchat' AS platform,
        s.ad_id,
        a.ad_name,
        a.ad_group_id,
        g.ad_group_name,
        g.campaign_id,
        c.campaign_name,
        c.account_id,
        s.currency_code,
        s.country_code,
        s.ad_date,
        s.spend,
        s.impressions,
        s.clicks
    FROM stats s
    LEFT JOIN ads a
        ON s.ad_id = a.ad_id
    LEFT JOIN adgroups g
        ON a.ad_group_id = g.ad_group_id
    LEFT JOIN campaigns c
        ON g.campaign_id = c.campaign_id
)

SELECT * FROM final
