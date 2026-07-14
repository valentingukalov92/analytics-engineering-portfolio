# Teradata UDF Optimization: SUBSTR → STRTOK

## Context
A widely-used UDF extracted Unix timestamps from delimited strings. It was called
in 30+ daily pipelines, processing 100k-10M+ rows per run. Profiling showed CPU time was the bottleneck.

## Problem
The original implementation used 7 deeply nested `SUBSTR` calls (each operating
on the result of the previous one) to locate delimiter positions and extract
the target segment.

## Solution
Replaced multiple `SUBSTR` calls with a single `STRTOK`, which tokenizes the
string natively in one pass.

## Benchmark Results
| Metric | Original | Optimized | Improvement |
|--------|----------|-----------|-------------|
| CPU Time (total AMP-seconds) | ~34k | ~7.5k | ~4.5x reduction |
| I/O (KB) | ~200k | ~176k | almost unchanged |
| Rows processed | ~30M | ~30M | same |

*Tested on a 30M-row sample dataset. Results consistent across 5+ runs.*

## Files
- `original_udf.sql` — UDF before optimization
- `optimized_udf.sql` — UDF after optimization
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