WITH source AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_ads') }}
)

SELECT
    CAST(ad_id AS STRING) AS ad_id,
    CAST(ad_group_id AS STRING) AS ad_group_id,
    ad_name,
    ad_detail_updated_at AS ad_updated_at
FROM source
