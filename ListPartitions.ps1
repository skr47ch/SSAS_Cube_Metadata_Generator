param($ServerName=@("server1", "server2"))
$output = ''

# Headers
$output += "Server Name,Database Name,Cube Name,Measure Group Name,Partition Name" 
$output | Set-Content partitions.csv

foreach($srvr in $ServerName) {
    ## Add the AMO namespace
    $loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
    $server = New-Object Microsoft.AnalysisServices.Server

    $server.connect($srvr)
    if ($server.name -eq $null) {
     Write-Output ("Server '{0}' not found" -f $srvr)
     break
    }

    foreach ($database in $server.Databases) {
        foreach($cube in $database.Cubes) {
            foreach($measureGroup in $cube.MeasureGroups) {
                foreach($partition in $measureGroup.Partitions) {
                    ("{0},{1},{2},{3},{4}" -f 
                    $server.Name,
                    $database.Name,
                    $cube.Name,
                    $measureGroup.Name,
                    $partition.Name) | Add-Content partitions.csv
                }    
            }     
        }
    }
}
