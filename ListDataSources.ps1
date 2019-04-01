param($ServerName="myservername")

## Add the AMO namespace
$loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
$server = New-Object Microsoft.AnalysisServices.Server

$server.connect($ServerName)
if ($server.name -eq $null) {
 Write-Output ("Server '{0}' not found" -f $ServerName)
 break
}


# Headers
Write-Output("Server Name,Database Name,Data Source Name,Connection String")


foreach ($database in $server.Databases) {
    foreach ($datasource in $database.DataSources) {
        Write-Output("{0},{1},{2},{3}" -f $datasource.ParentServer.Name, $datasource.ParentDatabase, $datasource.Name, $datasource.ConnectionString)
    }
}
