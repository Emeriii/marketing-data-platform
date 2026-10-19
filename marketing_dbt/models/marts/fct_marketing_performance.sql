
{{ config(materialized='table') }}

WITH facebook AS (

    SELECT *
    FROM {{ ref('int_facebook_ads_performance') }}

),

snapchat AS (

    SELECT *
    FROM {{ ref('int_snapchat_ads_performance') }}

),

unified AS (

    SELECT
        platform,
        ad_id,
        ad_name,
        ad_group_id,
        ad_group_name,
        campaign_id,
        campaign_name,
        account_id,
        currency_code,
        country_code,
        ad_date,
        spend,
        impressions,
        clicks
    FROM facebook

    UNION ALL

    SELECT
        platform,
        ad_id,
        ad_name,
        ad_group_id,
        ad_group_name,
        campaign_id,
        campaign_name,
        account_id,
        currency_code,
        country_code,
        ad_date,
        spend,
        impressions,
        clicks
    FROM snapchat

),

final AS (

    SELECT
        SHA2(
            CONCAT_WS(
                '||',
                COALESCE(platform, '<NULL>'),
                COALESCE(ad_id, '<NULL>'),
                COALESCE(CAST(ad_date AS STRING), '<NULL>'),
                COALESCE(country_code, '<NULL>'),
                COALESCE(currency_code, '<NULL>')
            ),
            256
        ) AS marketing_performance_key,

        *,

        CASE
            WHEN impressions > 0
            THEN CAST(clicks AS DOUBLE) / impressions
        END AS ctr,

        CASE
            WHEN clicks > 0
            THEN CAST(spend AS DOUBLE) / clicks
        END AS cpc,

        CASE
            WHEN impressions > 0
            THEN CAST(spend AS DOUBLE) * 1000 / impressions
        END AS cpm

    FROM unified

)

SELECT *
FROM final
