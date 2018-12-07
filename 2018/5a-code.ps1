$instr = (gc .\5-input.txt -raw -encoding ascii).trim()
#$records = New-Object System.Collections.Generic.List[pscustomobject]

$rx = "(\w)\1"
$rx2 = "([a-z][A-Z]|[A-Z][a-z])"

#$matches=$null;"dabAcCaCBAcCcaDA" -cmatch "(\w)\1&([a-z][A-Z]|[A-Z][a-z])";$Matches

#$instr = "dabAcCaCBAcCcaDA"
$strbuild = [System.Text.StringBuilder]::new($instr)

#$imax = $strbuild.Length
$i=0
while ($i -lt $strbuild.length -1) {
    #$strbuild.tostring()

    $str = $strbuild.tostring($i,2)
    #$a = $i-2;if ($a -lt 0) {$a=0}
    #write-host -NoNewline "$($strbuild.tostring($a,6)) - $i $str - "
    if ($str.toupper() -imatch $rx -and $str -cmatch $rx2) {
        #write-host -foregroundcolor green " remove"
        $strbuild.remove($i,2) | out-null
        if ($i -gt 0) { $i-- } #back up to see if there's a new match
        #$imax-=2    
    } else {
        #write-host -foregroundcolor blue " next"
        $i++
    }
}

$strbuild.length
