WITH source AS (
    SELECT * FROM {{ source('facebook', 'facebook_campaigns') }}
)

SELECT
    CAST(campaign_id AS STRING) AS campaign_id,
    campaign_name,
    campaign_updated_at
FROM source
