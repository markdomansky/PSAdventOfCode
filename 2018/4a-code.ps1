$inputs = gc .\4-input.txt | sort
$imax = $inputs.Count
$records = New-Object System.Collections.Generic.List[pscustomobject]

$GuardID = $null
$newobj = $null
for ($i=0;$i -lt $imax; $i++) {
    $row = $inputs[$i]
    $rx1 = "\[(?<dt>\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] Guard #(?<IDX>\d+) begins shift"
    $rx2 = "\[(?<dt>\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] falls asleep"
    $rx3 = "\[(?<dt>\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] wakes up"

    if ($row -match $rx1) {
        $guardid = $matches["IDX"]
    } elseif ($row -match $rx2) {
        $newobj = [PSCustomObject]@{
            GuardID = $GuardID
            DTStart = get-date $matches["dt"]
            DTEnd = $null
            Delta = 0
        }
    } elseif ($row -match $rx3) {
        $newobj.DTEnd = get-date $matches["dt"]
        $newobj.delta = ($newobj.dtend - $newobj.dtstart).totalminutes
        $records.add($newobj)
        $newobj = $null
    } else {
        write-host "No RX match for '$row'"
    }

}

#calc which minutes each guard is asleep
$guards = $records | group GuardID 

#calculate most asleep minute per guard
$guards | %{$_ | add-member -name "Sleep" -MemberType NoteProperty -value (($_.group | measure delta -sum).sum)}



$guards | %{$_ | add-member -MemberType noteproperty -Name SleepSched -Value $null}

$guards | %{$_.sleepsched = (New-Object System.Collections.Generic.List[pscustomobject])}
foreach ($guard in $guards) {
    for ($min=0;$min -lt 60; $min++) {
        $rec = [pscustomobject]@{"Min"=$min;"SleepCount"=0}
        foreach ($row in $guard.group) {
            #"$min $($row.dtstart) $($row.dtend)"
            if ($row.dtstart.minute -le $min -and $row.dtend.minute -gt $min) {$rec.sleepcount++;}
        }
        $guard.sleepsched.add($rec)
    }
}

$guards | %{$_ | add-member -MemberType noteproperty -Name SleepMin -Value $null}

$guards | %{$_.sleepmin = 0}
foreach ($guard in $guards) {
    $guard.sleepmin = ($guard.sleepsched | sort sleepcount -desc | select -first 1).min
}

$guards | sort sleep -desc | select -first 1 | ft name,sleep,sleepmin,@{Label="Mult";Expression={[int64]$_.name * $_.SleepMin} }

