install-module threadjob -scope currentuser

$test=""
#$test=".test"
$incsv = import-csv ".\6-input$test.txt" -Header @("X","Y")
$incsv | %{[int16]$_.x = $_.x;[int16]$_.y = $_.y;} #get x and y as integers
$incsv | %{$_ | add-member -MemberType noteproperty -name "ID" -value "-"} #for debugging
$incsv | %{$_ | add-member -MemberType NoteProperty -name "Area" -value 1} #store area here
$incsv | %{$_ | add-member -MemberType noteproperty -name "Edge" -value $false} #store if we hit edge
$incsv = $incsv | sort x,y

$nullchar = "~"
$chars = 65..90 + 97..122
for ($i=0;$i -lt $incsv.count; $i++) {
    $incsv[$i].ID = [char]($chars[$i])
}
#$records = New-Object System.Collections.Generic.List[pscustomobject]

#this is my grid.  Anything that hits min or max will be considered infinite
$minX = $incsv | sort X | select -first 1 -ExpandProperty X
$maxX = $incsv | sort X | select -last 1 -expandproperty X
$minY = $incsv | sort Y | select -first 1 -ExpandProperty Y
$maxY = $incsv | sort Y | select -last 1 -expandproperty Y
"X: $minx - $maxX"
"Y: $miny - $maxy"

$head = @"
<html>
    <head>
        <style>
            body {
                background-color: #303030;
            }
            .N {
                color: #606060;
            }
            .base {
                color: cyan;
                font-family: monospace;
                font-size: 10px;
                width: 1em;
                height: 1em;
                text-align: center;
                display: inline-block;
            }
            .P {
                color: yellow;
            }
        </style>
    </head>
    <body>
        <div class="base">
"@
$foot = @"
</div>
</body>
</html>
"@
$ErrorActionPreference = "Stop"
#$strout = [System.Text.StringBuilder]::new()
#$strout.AppendLine($head) | out-null

$GetTotalDist =  {param($X, $Y, $incsv)
    $totaldist = 0
    foreach ($row in $incsv) {
        $totaldist += [Math]::Abs($x - $row.x) + [Math]::abs($y-$row.y)
    }

    return [pscustomobject]@{"X"=$x;"Y"=$y;"TotalDist"=$totaldist}
}

$GetTotalDistRange =  {param($Y, $minx, $maxx, $incsv)
    foreach ($x in ($minxx..$maxx)) {
        $totaldist = 0
        foreach ($row in $incsv) {
            $totaldist += [Math]::Abs($x - $row.x) + [Math]::abs($y-$row.y)
        }
        write-output ([pscustomobject]@{"X"=$x;"Y"=$y;"TotalDist"=$totaldist})
    }
}

function GetTotalDist($X, $Y, $incsv) {
    $totaldist = 0
    foreach ($row in $incsv) {
        $totaldist += [Math]::Abs($x - $row.x) + [Math]::abs($y-$row.y)
    }

    return [pscustomobject]@{"X"=$x;"Y"=$y;"TotalDist"=$totaldist}
}

$distlist = New-Object System.Collections.Generic.List[object]
$joblist = New-Object System.Collections.Generic.List[object]
foreach ($y in ($minY..$maxY)) {
    $y
    $newjob = start-threadjob -name "$y" -ScriptBlock $GetTotalDistRange -ArgumentList @($y,$minx,$maxx,$incsv) -ThrottleLimit 4
    $joblist.add($newjob.name)

    foreach ($job in (get-job -HasMoreData $true -State completed)) {
        receive-job $job | %{$distlist.add($_)} | out-null
        $joblist.remove($job.name) | out-null
    }
}

#$distlist | ft
write-host "Jobs left:"
while ($joblist.count -gt 0) {
    $joblist.count
    foreach ($job in (get-job -HasMoreData $true -State completed)) {
        $distlist.add((receive-job $job)) | out-null
        $joblist.remove($job.name) | out-null
    }
    sleep -seconds 1
}


#$strout.AppendLine($foot)
#$strout.ToString() | out-file ".\6b-display$test.html" -Encoding ascii

#$incsv | sort y,x | ft

#$incsv | ?{$_.edge -eq $false} | sort area | select -last 1 | ft

#$distlist | ?{$_.totaldist -lt 32} | measure | select -expand count
$distlist | ?{$_.totaldist -lt 10000} | measure | select -expand count
