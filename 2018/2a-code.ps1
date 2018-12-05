$inputs = gc .\2-input.txt
$twos = 0
$threes = 0

$inputs | %{
    $str = $_
    
    $linearr = $str -split "(?!\b)" 
    $counts = $linearr | group 
    $countsummary = $counts | ?{$_.count -ne 1} | group count
    if ($countsummary | ?{$_.name -eq "2"}) {$twos++}
    if ($countsummary | ?{$_.name -eq "3"}) {$threes++}

}
$twos*$threes