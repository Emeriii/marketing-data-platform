WITH source AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_ads_stats') }}
)

SELECT
    CAST(ad_detail_id AS STRING) AS ad_id,
    TRY_CAST(ad_date AS DATE) AS ad_date,
    UPPER(TRIM(ad_currency_code)) AS currency_code,
    UPPER(TRIM(ad_country)) AS country_code,
    TRY_CAST(ad_spend AS DECIMAL(18,4)) AS spend,
    TRY_CAST(ad_impressions AS BIGINT) AS impressions,
    TRY_CAST(ad_clicks AS BIGINT) AS clicks,
    data_src
FROM source
