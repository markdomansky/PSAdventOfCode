$instr = (gc .\5-input.txt -raw -encoding ascii).trim()
#$instr = "dabAcCaCBAcCcaDA"
#$records = New-Object System.Collections.Generic.List[pscustomobject]

$chars = New-Object System.Collections.Generic.List[pscustomobject]
65..90 | %{
    $chars.add([char]($_))
}

function Reduce($strin) {
    $rx = "(\w)\1"
    $rx2 = "([a-z][A-Z]|[A-Z][a-z])"

    $strbuild = [System.Text.StringBuilder]::new($strin)
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

    return $strbuild.ToString()
}

function Remove($strin, [string]$char) {

    return $strin.replace($char.tolower(),"").replace($char.toupper(),"")
}


#$strout = reduce $instr
#$strout.length

$vals =  New-Object System.Collections.Generic.List[pscustomobject]
foreach ($c in $chars)
{
    $vals.add([pscustomobject]@{"C"=$c;"L"=(reduce (remove $instr $c)).length})

}
#$results | ft

$vals | sort L -desc | select -last 1