$inputs = gc .\3-input.txt
$maxX = 999
$maxY = 999
$fabric = new-object 'int64[,]' $maxx, $maxy

$ErrorActionPreference = "Stop"
$idxes = New-Object System.Collections.Generic.List[int64]
foreach ($row in $inputs) {

    $rx = "#(?<idx>\d+) @ (?<offX>\d+),(?<offY>\d+): (?<width>\d+)x(?<height>\d+)"
    $matched = $row -match $rx
    if ($matched) {
        for ($x = [int64]$matches["offX"]; $x -lt ([int64]$matches["offX"] + [int64]$matches["width"]); $x++) {
            for ($y = [int64]$matches["offY"]; $y -lt ([int64]$matches["offY"] + [int64]$matches["height"]); $y++) {
                #"$x,$y"
                $fabric[$x, $y]++
            }
        }
    }
    else {"No Match for '$row'"}
}

$idxes = New-Object System.Collections.Generic.List[int64]
foreach ($row in $inputs) {

    $rx = "#(?<idx>\d+) @ (?<offX>\d+),(?<offY>\d+): (?<width>\d+)x(?<height>\d+)"
    $matched = $row -match $rx
    if ($matched) {
        $overlap = $false
        for ($x = [int64]$matches["offX"]; $x -lt ([int64]$matches["offX"] + [int64]$matches["width"]); $x++) {
            for ($y = [int64]$matches["offY"]; $y -lt ([int64]$matches["offY"] + [int64]$matches["height"]); $y++) {
                #"$x,$y"
                if ($fabric[$x, $y] -gt 1) {$overlap = $true}
            }
        }
        if (-not $overlap) {$idxes.add($matches["idx"])}
    }
    else {"No Match for '$row'"}
}
$idxes