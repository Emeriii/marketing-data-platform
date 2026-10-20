
WITH source AS (

    SELECT *
    FROM {{ ref('stg_snapchat_adgroups') }}

),

ranked AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ad_group_id
            ORDER BY
                ad_group_updated_at DESC NULLS LAST,
                surrogate_key DESC
        ) AS row_num
    FROM source

),

final AS (

    SELECT
        surrogate_key,
        ad_group_id,
        campaign_id,
        ad_group_name,
        ad_group_updated_at
    FROM ranked
    WHERE row_num = 1

)

SELECT * FROM final 
