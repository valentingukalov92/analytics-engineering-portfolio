"""
Test Data Generator for Teradata UDF Optimization Benchmark

Generates valid offer_id strings that can be decoded by
get_OfferResponseDttm_from_OfferId() into valid timestamps.

Output: test_ids.csv (10,000 rows by default)
"""

import base64
import csv
import random


def generate_offer_id():
    """
    Generates a single valid offer_id.

    Internal structure (before base64 encoding):
        {random_prefix}_{random_numeric_id}_{unix_timestamp_ms}

    After base64 encoding, the result matches the format expected by decode_OfferId().
    """
    # Random alphanumeric prefix (8–20 characters)
    prefix = ''.join(random.choices(
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
        k=random.randint(8, 20)
    ))

    # Random numeric ID (12–15 digits)
    numeric_id = random.randint(10**11, 10**15 - 1)

    # Random Unix timestamp in milliseconds (range: 2020–2025)
    unix_time_ms = random.randint(1577836800000, 1735689600000)

    # Build the decoded string
    decoded_string = f"{prefix}_{numeric_id}_{unix_time_ms}"

    # Encode to URL-safe base64 (Teradata-compatible)
    encoded_bytes = base64.urlsafe_b64encode(decoded_string.encode('ascii'))
    offer_id = encoded_bytes.decode('ascii')

    return offer_id


if __name__ == "__main__":
    OUTPUT_FILE = "test_ids.csv"
    ROW_COUNT = 10_000

    with open(OUTPUT_FILE, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['offer_id'])
        for _ in range(ROW_COUNT):
            writer.writerow([generate_offer_id()])

    print(f"Generated {ROW_COUNT:,} test IDs → {OUTPUT_FILE}")