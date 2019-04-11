param($ServerName=@("server1", "server2"))
$output = ''

# Headers
$output += "Server Name,Database Name,Dimension Name,DataSourceView Name,Source Table,Attribute Name,Source Column,Attribute DataType,Attribute Size"
$output | Set-Content dimensionattributes.csv

foreach($srvr in $ServerName) {
    ## Add the AMO namespace
    $loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
    $server = New-Object Microsoft.AnalysisServices.Server

    $server.connect($ServerName)
    if ($server.name -eq $null) {
     Write-Output ("Server '{0}' not found" -f $ServerName)
     break
    }

    foreach ($database in $server.Databases) {
        foreach($dimension in $database.Dimensions) {
            foreach($dimensionAtt in $dimension.Attributes) {
                if ($server.ServerMode -eq "Tabular" -and $dimensionAtt.Name -eq "RowNumber") {continue}

                Write-Output("{0},{1},{2},{3},{4},{5},{6},{7},{8}" -f  
                $server.Name, 
                $database.Name, 
                $dimension.Name, 
                $dimension.DataSourceView.ID, 
                $dimensionAtt.NameColumn.Source.TableID, 
                $dimensionAtt.Name, 
                $dimensionAtt.NameColumn.Source.ColumnID, 
                $dimensionAtt.KeyColumns[0].DataType, 
                $dimensionAtt.KeyColumns[0].DataSize) | Add-Content dimensionattributes.csv
            }        
        }
    }
}
