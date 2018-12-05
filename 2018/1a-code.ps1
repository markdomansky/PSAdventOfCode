$input = gc "1-input.txt"
$output = 0
$input | %{
    "$output + $_"
    $output += $_
}
$output