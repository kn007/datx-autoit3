#include <Array.au3>
#include "City.au3"

Dim $hTimer, $iDiff

$hTimer = TimerInit()

Local $test = FindIP('1.8.18.255')

$iDiff = TimerDiff($hTimer)

_ArrayDisplay($test, '耗时：'&$iDiff&' ms')

Exit
