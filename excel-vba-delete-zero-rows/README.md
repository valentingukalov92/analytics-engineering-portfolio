# Excel VBA Macro: Multi-Sheet Zero Row Removal

## Context
Purchasing managers at a 130+ store retail chain prepared order files with
130+ worksheets for each contractor. 
Rows with zero quantities (column B) had to be manually
removed from every sheet before ERP upload.

## Problem
Manual cleanup: ~up to 10 minutes per file, 30 managers, 2–5 files/week each.
Estimated waste: **15 hours/week** for whole department.

## Solution
VBA macro loops through all worksheets, deletes rows where:
- Column A has a product ID (row is in use)
- Column B is empty or zero (no quantity ordered)

## Impact
- Manual time per file: ~10 min → ~1 min
- Weekly savings: ~15+ hours across 30 users
- Zero errors from missed rows (macro doesn't skip sheets)

## Files
- `remove_zero_rows.bas` — VBA macro code

## Sample Files
- `sample_before.xlsm` — test file with zero rows (run macro on this)
- `sample_after.xlsm` — result after macro execution

## Key Takeaways
- Simple automation × many users × high frequency = massive savings
- Understanding the full business process (not just the data request) reveals
  where automation matters most