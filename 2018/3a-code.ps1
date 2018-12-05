$inputs = gc .\3-input.txt
$maxX = 999
$maxY = 999
$fabric = new-object 'int64[,]' $maxx, $maxy

$ErrorActionPreference = "Stop"
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

$overlaps = 0
for ($x = 0; $x -le $maxx; $x++) {
    for ($y = 0; $y -le $maxy; $y++) {
        if ($fabric[$x, $y] -gt 1) {$overlaps++}
    }
}

$overlaps