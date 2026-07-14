-- Original UDF: get_OfferResponseDttmUnixTime_from_OfferId
-- Extracts Unix timestamp (milliseconds) from a decoded offer_id string.
--
-- Problem: decode_OfferId() is called 7 times within nested SUBSTR/INSTR
-- expressions. Teradata does not cache the result of the udf, so each
-- invocation triggers a full base64-decode of the input string.
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
    CAST(
        SUBSTR(
            decode_OfferId(offer_id),          -- call 1
            INSTR(
                decode_OfferId(offer_id),      -- call 2
                '_', 1, 2
            ) + 1,
            CASE
                WHEN INSTR(
                    decode_OfferId(offer_id),  -- call 3
                    '_', 1, 3
                ) = 0
                THEN LENGTH(
                    decode_OfferId(offer_id)   -- call 4
                ) - INSTR(
                    decode_OfferId(offer_id),  -- call 5
                    '_', 1, 2
                )
                ELSE INSTR(
                    decode_OfferId(offer_id),  -- call 6
                    '_', 1, 3
                ) - INSTR(
                    decode_OfferId(offer_id),  -- call 7
                    '_', 1, 2
                ) - 1
            END
        ) AS BIGINT
    );