
WITH stats AS (
    SELECT *
    FROM {{ ref('stg_facebook_ads_stats') }}
),

ads AS (
    SELECT *
    FROM {{ ref('stg_facebook_ads') }}
),

campaigns AS (
    SELECT *
    FROM {{ ref('stg_facebook_campaigns') }}
),

adgroups AS (
    SELECT *
    FROM {{ ref('stg_facebook_adgroups') }}
),

accounts AS (
    SELECT *
    FROM {{ ref('stg_facebook_accounts') }}
),

final AS (
    SELECT
        'facebook' AS platform,
        s.ad_id,
        a.ad_name,
        a.ad_group_id,
        g.ad_group_name,
        a.campaign_id,
        c.campaign_name,
        s.account_id,
        acc.currency_code,
        CAST(NULL AS STRING) AS country_code,
        s.date AS ad_date,
        s.spend,
        s.impressions,
        s.clicks
    FROM stats s
    LEFT JOIN ads a
        ON s.ad_id = a.ad_id
    LEFT JOIN campaigns c
        ON a.campaign_id = c.campaign_id
    LEFT JOIN adgroups g
        ON a.ad_group_id = g.ad_group_id
    LEFT JOIN accounts acc
        ON s.account_id = acc.account_id
)

SELECT * FROM final


