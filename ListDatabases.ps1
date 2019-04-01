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
Write-Output("Server Name,Database Name")


foreach ($database in $server.Databases) {
    Write-Output("{0},{1}" -f $database.ParentServer.Name, $database.Name)

}
