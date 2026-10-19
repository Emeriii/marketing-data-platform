WITH source AS (
    SELECT * FROM {{ source('facebook', 'facebook_adgroups') }}
)

SELECT
    CAST(ad_group_id AS STRING) AS ad_group_id,
    ad_group_name,
    ad_group_updated_at
FROM source
