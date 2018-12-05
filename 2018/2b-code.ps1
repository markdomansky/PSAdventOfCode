$inputs = gc .\2-input.txt

$inmax = $inputs.Count

$cmax = $inputs[0].Length

for ($a=0;$a -lt $inmax-1;$a++) {
    $stra = $inputs[$a]
    for ($b=$a+1;$b -lt $inmax; $b++) {
        $strb = $inputs[$b]

        #"$a $b"
        $diffcnt=0
        for ($c=0;$c -lt $cmax;$c++) {
            if ($stra[$c] -ne $strb[$c]) {
                $diffcnt++
                if ($diffcnt -gt 2) {break}
            }
        }
        if ($diffcnt -eq 1) {
            $stra
            $strb

            $outstr = ""
            for ($c=0;$c -lt $cmax;$c++) {
                if ($stra[$c] -eq $strb[$c]) {
                    $outstr += $stra[$c]
                }
            }
    
            return $outstr
        }
        

    }
}