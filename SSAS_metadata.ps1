param($ServerName="myservername")
$path = ".\MyFolder\SSAS_metadata.json"

## Add the AMO namespace
$loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
$server = New-Object Microsoft.AnalysisServices.Server

$server.connect($ServerName)
if ($server.name -eq $null) {
 Write-Output ("Server '{0}' not found" -f $ServerName)
 break
}


$output = [ordered]@{ database=@() }

$db_index = 0
foreach ($database in $server.Databases) {

    $db_name = $database.Name
    $db_status = $database.State
    $db_size = ($database.EstimatedSize/1024/1024).ToString("#,##0") + " MB"
    $db_last_update = $database.LastUpdate.ToString('yyyy-MM-dd')
    $db_last_schema_update = $database.LastSchemaUpdate.ToString('yyyy-MM-dd')
    $db_last_processed = $database.LastProcessed.ToString('yyyy-MM-dd')
     
    $output.database += @( [ordered]@{ db_name="$db_name"; db_status="$db_status"; db_size="$db_size"; db_last_update=$db_last_update; db_last_schema_update=$db_last_schema_update; db_last_processed=$db_last_processed; datasource=@(); datasourceview=@(); dimension=@(); cube=@() } )

    
    foreach ($datasource in $database.DataSources) {
        
        $datasource_name = $datasource.Name
        $datasource_connection_string = $datasource.ConnectionString
        
        $output.database[$db_index].datasource += @( [ordered]@{ datasource_name="$datasource_name"; datasource_connection_string="$datasource_connection_string" } )
    }


    $dsv_index = 0
    foreach ($dataSourceView in $database.DataSourceViews) {
        
        $datasourceview_id= $dataSourceView.ID
        $datasourceview_name = $dataSourceView.Name

        $output.database[$db_index].datasourceview += @( [ordered]@{ datasourceview_id=$datasourceview_id; datasourceview_name=$datasourceview_name; dsv_table=@() } )
        
        $dsv_table_index = 0
        foreach ($table in $dataSourceView.Schema.Tables) {
            
            $dsv_table_id=$table.TableName
            $dsv_table_name=$table.ExtendedProperties["FriendlyName"]
            $dsv_table_query=$table.ExtendedProperties["QueryDefinition"]
            if($table.ExtendedProperties["DataSourceID"] -eq $null) { 
                $dsv_data_source_name = $dataSourceView.DataSource.ID 
            }
            else { 
                $dsv_data_source_name = $table.ExtendedProperties["DataSourceID"] 
            }

            $output.database[$db_index].datasourceview[$dsv_index].dsv_table += @( [ordered]@{ dsv_data_source_name=$dsv_data_source_name; dsv_table_id=$dsv_table_id; dsv_table_name=$dsv_table_name; dsv_table_query=$dsv_table_query; dsv_column=@() } )

            foreach ($column in $table.Columns) {
                               
                $dsv_column_name=$column.ColumnName
                $dsv_column_data_type=$column.DataType
                $dsv_column_data_size=$column.MaxLength

                $output.database[$db_index].datasourceview[$dsv_index].dsv_table[$dsv_table_index].dsv_column += @( [ordered]@{ dsv_column_name=$dsv_column_name; dsv_column_data_type=$dsv_column_data_type; dsv_column_data_size=$dsv_column_data_size } )

            } $dsv_table_index += 1

        } $dsv_index += 1

    }


    foreach ($dimension in $database.Dimensions) {
        
        $dimension_name = $dimension.Name
        $dimension_status = $dimension.State
        $dimension_size = ($dimension.EstimatedSize/1024/1024).ToString("#,##0") + " MB"
        $dimension_last_processed = $dimension.LastProcessed.ToString('yyyy-MM-dd')

        $output.database[$db_index].dimension += @( [ordered]@{ dimension_name="$dimension_name"; dimension_status="$dimension_status"; dimension_size="$dimension_size"; dimension_last_processed=$dimension_last_processed } )
    }


    $cube_index = 0
    foreach ($cube in $database.Cubes) {

        $cube_name = $cube.Name
        $cube_status = $cube.State
        $cube_last_processed = $cube.LastProcessed.ToString('yyyy-MM-dd')

        $output.database[$db_index].cube += @( [ordered]@{ cube_name="$cube_name"; cube_status="$cube_status"; cube_last_processed=$cube_last_processed; measure_group=@() } )


        $measure_group_index = 0
        foreach ($measure_group in $cube.MeasureGroups) {
        
            $measure_group_name = $measure_group.Name
            $measure_group_status = $measure_group.State
            $measure_group_data_source_name = $measure_group.Partitions[0].DataSource.Name
            $measure_group_size = ($measure_group.EstimatedSize/1024/1024).ToString("#,##0") + " MB"
            $measure_group_last_processed = $measure_group.LastProcessed.ToString('yyyy-MM-dd')

            $output.database[$db_index].cube[$cube_index].measure_group += @( [ordered]@{ measure_group_name="$measure_group_name"; measure_group_status="$measure_group_status";measure_group_data_source_name = $measure_group_data_source_name; measure_group_size="$measure_group_size"; measure_group_last_processed=$measure_group_last_processed; measure=@(); partition=@() } )
            
           
            foreach ($measure in $measure_group.Measures) {
                
                $measure_name = $measure.Name
                $measure_source_table_name = $measure.Source.Source.TableID
                $measure_source_column = $measure.Source.Source.ColumnID

                $output.database[$db_index].cube[$cube_index].measure_group[$measure_group_index].measure += @( [ordered]@{ measure_name="$measure_name"; measure_data_source_name = $measure_group_data_source_name; measure_source_table_name=$measure_source_table_name; measure_source_column=$measure_source_column } )

            }
            
            foreach ($partition in $measure_group.Partitions) {
                
                $partition_name = $partition.Name
                $partition_status = $partition.State
                $partition_size = ($partition.EstimatedSize/1024/1024).ToString("#,##0") + " MB"
                $partion_last_processed = $partition.LastProcessed.ToString('yyyy-MM-dd')

                $output.database[$db_index].cube[$cube_index].measure_group[$measure_group_index].partition += @( [ordered]@{ partition_name="$partition_name"; partition_status=$partition_status; partition_size=$partition_size; partion_last_processed=$partion_last_processed } )

            }
            $measure_group_index += 1
        }
        $cube_index += 1
    }
    $db_index += 1
}

$output = $output | ConvertTo-Json -Depth 99 
Write-Output($output)

[System.IO.File]::WriteAllText($path,$output,[System.Text.Encoding]::GetEncoding('iso-8859-1'))
