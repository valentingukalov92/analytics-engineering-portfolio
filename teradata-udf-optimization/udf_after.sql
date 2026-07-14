-- Optimized UDF: get_OfferResponseDttmUnixTime_from_OfferId
-- Extracts Unix timestamp (milliseconds) from a decoded offer_id string.
--
-- Improvement: replaced 7 nested SUBSTR/INSTR calls (each invoking
-- decode_OfferId) with a single STRTOK call. decode_OfferId is now
-- called only once per row.
--
-- Additionally: added NULL handling for robustness.
--
-- Called by: get_OfferResponseDttm_from_OfferId (unchanged, not shown)

REPLACE FUNCTION get_OfferResponseDttmUnixTime_from_OfferId(
    offer_id VARCHAR(350) CHARACTER SET LATIN
)
RETURNS BIGINT
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COLLATION INVOKER
INLINE TYPE 1

RETURN
    CASE
        WHEN offer_id IS NULL THEN NULL
        ELSE CAST(
            STRTOK(
                decode_OfferId(offer_id),  -- single call
                '_',
                3
            ) AS BIGINT
        )
    END;