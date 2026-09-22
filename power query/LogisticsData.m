let
    Source = Csv.Document(File.Contents("C:\Users\hp\Downloads\global_supply_chain_risk_2026.csv"),[Delimiter=",", Columns=14, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Shipment_ID", type text}, {"Date", type date}, {"Origin_Port", type text}, {"Destination_Port", type text}, {"Transport_Mode", type text}, {"Product_Category", type text}, {"Distance_km", type number}, {"Weight_MT", type number}, {"Fuel_Price_Index", type number}, {"Geopolitical_Risk_Score", type number}, {"Weather_Condition", type text}, {"Carrier_Reliability_Score", type number}, {"Lead_Time_Days", type number}, {"Disruption_Occurred", Int64.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each true),
    #"Trimmed Text" = Table.TransformColumns(#"Filtered Rows",{{"Origin_Port", Text.Trim, type text}, {"Destination_Port", Text.Trim, type text}, {"Transport_Mode", Text.Trim, type text}, {"Product_Category", Text.Trim, type text}, {"Weather_Condition", Text.Trim, type text}}),
    #"Capitalized Each Word" = Table.TransformColumns(#"Trimmed Text",{{"Origin_Port", Text.Proper, type text}, {"Destination_Port", Text.Proper, type text}, {"Transport_Mode", Text.Proper, type text}, {"Product_Category", Text.Proper, type text}, {"Weather_Condition", Text.Proper, type text}}),
    #"Filtered Rows1" = Table.SelectRows(#"Capitalized Each Word", each true),
    #"Changed Type1" = Table.TransformColumnTypes(#"Filtered Rows1",{{"Distance_km", Int64.Type}, {"Weight_MT", Int64.Type}, {"Lead_Time_Days", Int64.Type}}),
    #"Filtered Rows2" = Table.SelectRows(#"Changed Type1", each true),
    #"Removed Duplicates" = Table.Distinct(#"Filtered Rows2", {"Shipment_ID"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Duplicates", "Fuel_Price_Bracket", each if [Fuel_Price_Index] <= 2 then "Low Fuel ($1-$2)" else if [Fuel_Price_Index] <= 3.5 then "Mid Fuel ($2-$3.5)" else "High Fuel (>$3.5)"),
    #"Filtered Rows3" = Table.SelectRows(#"Added Conditional Column", each true),
    #"Added Custom" = Table.AddColumn(#"Filtered Rows3", "Mode_Route_Flag", each if ([Transport_Mode] = "Rail" or [Transport_Mode] = "Road") and [Distance_km] > 3000 then "Flag - Implausible Mode/Distance" else "OK"),
    #"Replaced Value" = Table.ReplaceValue(#"Added Custom","Flag - Implausible Mode/Distance","Flagged",Replacer.ReplaceText,{"Mode_Route_Flag"}),
    #"Filtered Rows4" = Table.SelectRows(#"Replaced Value", each true),
    #"Merged Queries" = Table.NestedJoin(#"Filtered Rows4", {"Origin_Port"}, PortRef, {"Port"}, "PortRef", JoinKind.LeftOuter),
    #"Expanded PortRef" = Table.ExpandTableColumn(#"Merged Queries", "PortRef", {"Continent"}, {"Continent"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded PortRef",{{"Continent", "Origin_Continent"}}),
    #"Merged Queries1" = Table.NestedJoin(#"Renamed Columns", {"Destination_Port"}, PortRef, {"Port"}, "PortRef", JoinKind.LeftOuter),
    #"Expanded PortRef1" = Table.ExpandTableColumn(#"Merged Queries1", "PortRef", {"Continent"}, {"Continent"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded PortRef1",{{"Continent", "Destination_Continent"}}),
    #"Filtered Rows5" = Table.SelectRows(#"Renamed Columns1", each true),
    #"Replaced Value1" = Table.ReplaceValue(#"Filtered Rows5","MiddleEast","Middle East",Replacer.ReplaceText,{"Origin_Continent"}),
    #"Replaced Value2" = Table.ReplaceValue(#"Replaced Value1","MiddleEast","Middle East",Replacer.ReplaceText,{"Destination_Continent"}),
    #"Replaced Value3" = Table.ReplaceValue(#"Replaced Value2","NorthAmerica","North America",Replacer.ReplaceText,{"Origin_Continent"}),
    #"Replaced Value4" = Table.ReplaceValue(#"Replaced Value3","NorthAmerica","North America  ",Replacer.ReplaceText,{"Destination_Continent"}),
    #"Trimmed Text1" = Table.TransformColumns(#"Replaced Value4",{{"Origin_Continent", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text1",{{"Origin_Continent", Text.Clean, type text}}),
    #"Trimmed Text2" = Table.TransformColumns(#"Cleaned Text",{{"Destination_Continent", Text.Trim, type text}}),
    #"Cleaned Text1" = Table.TransformColumns(#"Trimmed Text2",{{"Destination_Continent", Text.Clean, type text}}),
    #"Added Custom1" = Table.AddColumn(#"Cleaned Text1", "Cross_Continent", each if [Origin_Continent] = [Destination_Continent] then "Same" else "Cross"),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Route_Plausibility", each if [Cross_Continent] = "Same" then "OK"
else if [Transport_Mode] = "Rail" or [Transport_Mode] = "Road" then "Flag - Implausible Mode/Route"
else "OK"),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Fuel_Bracket_Label", each if [Fuel_Price_Bracket] = "Low Fuel ($1-$2)" then "Low Index (1.0–2.0)"
else if [Fuel_Price_Bracket] = "Mid Fuel ($2-$3.5)" then "Mid Index (2.0–3.5)"
else if [Fuel_Price_Bracket] = "High Fuel (>$3.5)" then "High Index (>3.5)"
else [Fuel_Price_Bracket]),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom3",{{"Disruption_Occurred", type number}, {"Lead_Time_Days", type number}}),
    #"Filtered Rows6" = Table.SelectRows(#"Changed Type2", each true),
    #"Changed Type3" = Table.TransformColumnTypes(#"Filtered Rows6",{{"Route_Plausibility", type text}, {"Cross_Continent", type text}, {"Distance_km", type number}, {"Weight_MT", type number}})
in
    #"Changed Type3"