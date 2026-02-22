# Error Budget Cheatsheet

Author: Simon Parris  
Date: 2026-02-22

## Formula

Error budget = `100% - SLO target`

Example:

- Availability SLO = `99.9%`
- Error budget = `0.1%`

## Downtime equivalents (approx)

For `99.9%` availability:

- per 30 days: `~43m 12s`
- per 7 days: `~10m 05s`
- per 24 hours: `~1m 26s`

For `99.95%` availability:

- per 30 days: `~21m 36s`

For `99.99%` availability:

- per 30 days: `~4m 19s`

## Why SRE teams care

- Error budget spending informs release velocity vs reliability focus.
- If budget burn is too fast, reduce risky changes and prioritize reliability work.
