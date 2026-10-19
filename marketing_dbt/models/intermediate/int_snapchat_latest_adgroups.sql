
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



# Why I did this?
# I discovered an issue earlier?
# - Snapchat had 267 raw ad-group records.
# - Three ad-group IDs appeared twice.
# - Joining directly to the history table produced 25 additional advertisement rows.
# This model selects one current-state record per ad_group_id, using the latest update timestamp.
# We expect 264 records in the resulting model.


