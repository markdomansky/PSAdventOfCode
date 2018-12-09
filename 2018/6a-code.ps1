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
$minx--
$maxx++
$miny--
$maxy++
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
$strout = [System.Text.StringBuilder]::new()
$strout.AppendLine($head) | out-null

function GetOwner($X, $Y) {

    $distgrid = New-Object System.Collections.Generic.List[pscustomobject]
    foreach ($row in $incsv) {
        if ($row.x -eq $x -and $row.y -eq $y) {
            return $row.ID
        }
        $dist = [Math]::Abs($x - $row.x) + [Math]::abs($y-$row.y)
        $distgrid.add([pscustomobject]@{"ID"=$row.id;"Dist"=$dist})
    }
    #don't forget equidistant mindist matches

    $mindist = $distgrid | sort dist | select -first 1
    $count = $distgrid | ?{$_.dist -eq $mindist.dist} | measure | select -ExpandProperty count

    if ( $count -eq 1) {
        return ($mindist.id)
    } else {
        return $nullchar
    }
}

foreach ($y in ($minY..$maxY)) {
    $y
    foreach ($x in ($minX..$maxX)) {
        $ID = "="
        $ID = GetOwner $x $y
        $row =  $incsv | ?{$_.id -ceq $ID}

        if ($row -ne $null) {
            if ($x -eq $minx -or $x -eq $maxx -or $y -eq $miny -or $y -eq $maxy) {
                $row.Edge = $true
            }
        }

        if ($row -ne $null -and $row.x -eq $x -and $row.y -eq $y) {
            #home
            #write-host -NoNewline -ForegroundColor yellow $id
            $strout.append("<span class='P' title='$x,$y'>$id</span>") | out-null
        } elseif ($id -eq $nullchar) {
            #multimatch
            #write-host -NoNewline -ForegroundColor darkgray $id
            $strout.append("<span class='N' title='$x,$y'>$id</span>") | out-null
        } else {
            #singlematch
            #write-host -NoNewline -ForegroundColor cyan  $id
            $strout.append("<span           title='$x,$y'>$id</span>") | out-null
            $row.Area += 1
        }

    }
    #write-host " "
    $strout.AppendLine("<BR/>") | out-null
}


$strout.AppendLine($foot)
$strout.ToString() | out-file ".\6a-display$test.html" -Encoding ascii

$incsv | sort y,x | ft

$incsv | ?{$_.edge -eq $false} | sort area | select -last 1 | ft