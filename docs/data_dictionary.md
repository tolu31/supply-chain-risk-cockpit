# Data Dictionary

Source: `data/global_supply_chain_risk_2026.csv`
Rows: 5,000 | Columns: 14

| Column | Type | Description | Notes |
|---|---|---|---|
| Shipment_ID | Text | Unique shipment identifier | SC-10000 to SC-14999 |
| Date | Date | Shipment date | US format in source (M/D/YYYY) |
| Origin_Port | Text | Departure port | 8 distinct values |
| Destination_Port | Text | Arrival port | 8 distinct values |
| Transport_Mode | Text | Air / Rail / Road / Sea | 1,828 records flagged for implausible mode/route |
| Product_Category | Text | 5 categories | Automotive, Electronics, Perishables, Pharmaceuticals, Textiles |
| Distance_km | Decimal | Stated route distance | Not validated against great-circle distance |
| Weight_MT | Decimal | Cargo weight, metric tonnes | |
| Fuel_Price_Index | Decimal | Index value, not USD | 1.20 to 4.50 |
| Geopolitical_Risk_Score | Decimal | 0 to 10 | Higher = more risk |
| Weather_Condition | Text | Clear / Fog / Hurricane / Rain / Storm | |
| Carrier_Reliability_Score | Decimal | 0 to 1 | Route/mode reliability, NOT carrier reliability — no Carrier_ID in source |
| Lead_Time_Days | Decimal | Days | 409 records have 0.5 sentinel value |
| Disruption_Occurred | Binary | 1 = disrupted, 0 = clear | Used directly as disruption rate via AVERAGE |

## Derived columns (added in Power Query)

| Column | Type | Formula |
|---|---|---|
| Origin_Continent | Text | Lookup from PortRef |
| Destination_Continent | Text | Lookup from PortRef |
| Cross_Continent | Text | Same / Cross |
| Mode_Route_Flag | Text | Rail or Road with Distance_km > 3,000 → "Flag - Implausible Mode/Distance" |
| Route_Plausibility | Text | Rail or Road on Cross_Continent route → "Flag - Implausible Mode/Route" |
| Fuel_Bracket_Label | Text | Low / Mid / High Index |