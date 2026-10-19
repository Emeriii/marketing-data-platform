WITH source AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_adgroups') }}
)

SELECT
    CAST(_surrogate_key AS STRING) AS surrogate_key,
    CAST(ad_group_id AS STRING) AS ad_group_id,
    CAST(campaign_id AS STRING) AS campaign_id,
    ad_group_name,
    ad_group_updated_at
FROM source
