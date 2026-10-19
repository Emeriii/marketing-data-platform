WITH source AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_campaigns') }}
)

SELECT
    CAST(campaign_id AS STRING) AS campaign_id,
    CAST(account_id AS STRING) AS account_id,
    campaign_name
FROM source
