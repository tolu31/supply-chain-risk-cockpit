let
    Source = Excel.CurrentWorkbook(){[Name="PortRef"]}[Content],
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Port", type text}, {"Continent", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","NorthAmerica","North America",Replacer.ReplaceText,{"Continent"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","MiddleEast","Middle East",Replacer.ReplaceText,{"Continent"}),
    #"Trimmed Text" = Table.TransformColumns(#"Replaced Value1",{{"Continent", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"Continent", Text.Clean, type text}})
in
    #"Cleaned Text"