WITH source AS (
    SELECT * FROM {{ source('facebook', 'facebook_ads_stats') }}
)

SELECT
    CAST(ad_id AS STRING) AS ad_id,
    CAST(account_id AS STRING) AS account_id,
    TRY_CAST(ad_date AS DATE) AS date,
    TRY_CAST(ad_spend AS DECIMAL(18,4)) AS spend,
    TRY_CAST(ad_impressions AS BIGINT) AS impressions,
    TRY_CAST(ad_clicks AS BIGINT) AS clicks
FROM source
