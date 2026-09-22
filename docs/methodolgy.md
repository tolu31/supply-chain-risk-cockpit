# Methodology

## Data pipeline

1. CSV loaded via Power Query into Excel Data Model
2. PortRef lookup table loaded as separate query
3. Two merges on Origin_Port and Destination_Port add continent columns
4. Cross_Continent derived from continent equality
5. Route_Plausibility derived from Cross_Continent + Transport_Mode
6. All transformations documented in power_query/*.m

## Derived flags

**Route_Plausibility** — Primary data-confidence filter. Flags any Rail or Road
shipment on a cross-continent route, regardless of stated distance.

**Mode_Route_Flag** — Secondary filter. Flags Rail or Road with Distance_km >
3,000. Narrower than Route_Plausibility.

The two flags disagree on 154 records in each direction. Route_Plausibility is
used as the default slicer throughout the workbook.

## The stress-testing process

The workbook explicitly tests whether findings hold up on the plausible-only
subset. Two findings did not:

- **Rail fuel sensitivity** — 2.6-point decline on full dataset, reverses on
  clean subset. Withdrawn.
- **Textiles heaviest category** — Full dataset shows Textiles first (248.3 MT);
  clean subset shows Automotive first (247.2 MT). Corrected.

Both reversals are documented in the Engineering & Insights sheet rather than
silently corrected. This is deliberate — the reversals are the point.

## Why Excel

The task was analyst-grade reporting for a non-technical executive audience.
Excel's Data Model, Power Query, and GETPIVOTDATA bindings deliver this without
requiring a BI server. The workbook is designed to be opened, filtered, and
read without any tooling beyond Excel.