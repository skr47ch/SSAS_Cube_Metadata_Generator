param($ServerName=@("server1", "server2"))
$output = ''

# Headers
$output += "Server Name,Database Name,Cube Name,Measure Group Name,Data Source Name,Measure Name,Source Table,Source Column"
$output | Set-Content measures.csv

foreach($srvr in $ServerName) {
    ## Add the AMO namespace
    $loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
    $server = New-Object Microsoft.AnalysisServices.Server

    $server.connect($srvr)
    if ($server.name -eq $null) {
     Write-Output ("Server '{0}' not found" -f $ServerName)
     break
    }

    foreach ($database in $server.Databases) {
        foreach($cube in $database.Cubes) {
            foreach($measureGroup in $cube.MeasureGroups) {
                foreach($measure in $measureGroup.Measures) {

                    Write-Output("{0},{1},{2},{3},{4},{5},{6},{7}" -f 
                    $server.Name,
                    $database.Name,
                    $cube.Name,
                    $measureGroup.Name,
                    $measureGroup.Partitions[0].DataSource.Name,
                    $measure.Name,
                    $measure.Source.Source.TableID,
                    $measure.Source.Source.ColumnID) | Add-Content measures.csv
                }
            }     
        }
    }
}
