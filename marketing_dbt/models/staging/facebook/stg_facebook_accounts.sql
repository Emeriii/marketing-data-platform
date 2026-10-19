WITH source AS (
    SELECT * FROM {{ source('facebook', 'facebook_accounts') }}
)

SELECT
    CAST(account_id AS STRING) AS account_id,
    account_name,
    UPPER(TRIM(ad_currency_code)) AS currency_code,
    account_created_at,
    account_updated_at
FROM source
