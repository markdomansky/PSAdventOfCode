$found = New-Object System.Collections.Generic.List[int64]

$input = gc "1-input.txt"
$output = 0
do {
    $input | %{
        $found.add($output)
        #"$output + $_" #disabled for speed
        $output += $_
        if ($found.contains($output)) {
            break
        }
    }
} until ($found.contains($output) -eq $true)
"Repeat $output"
