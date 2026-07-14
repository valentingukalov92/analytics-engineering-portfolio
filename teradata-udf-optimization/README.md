# Teradata UDF Optimization: SUBSTR → STRTOK

## Context
A widely-used UDF extracted Unix timestamps from delimited strings. It is called
in 30+ daily pipelines, processing 100k-10M+ rows per run. Profiling showed CPU time was the bottleneck.

## Problem
The original implementation called `decode_SOfferId()` 7 times within nested
`SUBSTR` and `INSTR` expressions to locate and extract the third token from
the decoded string. Teradata does not cache UDF results, so each invocation
triggered a redundant base64-decode — wasting CPU on every row.

## Solution
Replaced the nested `SUBSTR`/`INSTR` calls with a single `STRTOK`, which
tokenizes the string natively and extracts the required token directly.
`decode_SOfferId` is now called once per row instead of 7 times. Also added
explicit NULL handling for input robustness.

## Benchmark Results
| Metric | Original | Optimized | Improvement |
|--------|----------|-----------|-------------|
| CPU Time (total AMP-seconds) | ~34k | ~7.5k | ~4.5x reduction |
| I/O (KB) | ~200k | ~176k | almost unchanged |
| Rows processed | ~30M | ~30M | same |

*Tested on a 30M-row sample dataset. Results consistent across 5+ runs.*

## Files
- `udf_before.sql` — UDF before optimization (7 nested SUBSTR calls)
- `udf_after.sql` — UDF after optimization (single STRTOK)
- `benchmark.sql` — test harness for reproducible comparison
- `generate_test_data.py` — test data generator for reproducible benchmarks

## Test Data
- `generate_test_data.py` — generates valid `offer_id` strings for
  benchmarking. Default output is 10,000 rows to keep the file size small
  and reproducible. For full-scale benchmarks, increase `ROW_COUNT` in
  the script (e.g. `ROW_COUNT = 30_000_000` for 30M rows).

## Key Takeaways
- Native tokenization functions (`STRTOK`) are significantly faster than
  manual substring parsing
- CPU-bound UDFs should be profiled and optimized — cumulative savings
  across daily runs can be significant
- Always benchmark on realistic data volumes before deploying

## Why STRTOK?
STRTOK is a Teradata built-in function implemented in C++, optimized for
tokenizing delimited strings in a single pass. Unlike SUBSTR, which requires
manual position tracking and nested calls, STRTOK natively splits the string
by delimiter and returns the n-th token directly.