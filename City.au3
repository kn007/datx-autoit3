#include-once
#include <WinAPI.au3>

Dim $IPIP_DATA = @ScriptDir&"\mydata4vipday2.datx"

Global Const $HX_REF = "0123456789ABCDEF"
Global Const $iIndexSize = _HexToDecimal(_BinaryMid($IPIP_DATA, 0, 1)&_BinaryMid($IPIP_DATA, 1, 1)&_BinaryMid($IPIP_DATA, 2, 1)&_BinaryMid($IPIP_DATA, 3, 1))

Func FindIP($IP)
	Local $iPos = 0
	Local $iMid = 0
	Local $iLow = 0
	Local $iHigh = Int(($iIndexSize - 262144 - 262148) / 9) - 1
	Local $iIP = _ip2long($IP)
	Local $iPrefix, $iSuffix, $iTmpPos, $iOffset, $iLength, $sData

	While $iLow <= $iHigh
		$iMid = Int(($iLow + $iHigh) / 2)
		$iPos = $iMid * 9 + 262148
		$iPrefix = 0

		If $iMid > 0 Then
			$iTmpPos = ($iMid - 1) * 9 + 262148
			$iPrefix = _HexToDecimal(_BinaryMid($IPIP_DATA, ($iTmpPos), 1)&_BinaryMid($IPIP_DATA, ($iTmpPos + 1), 1)&_BinaryMid($IPIP_DATA, ($iTmpPos + 2), 1)&_BinaryMid($IPIP_DATA, ($iTmpPos + 3), 1)) + 1
		EndIf

		$iSuffix = _HexToDecimal(_BinaryMid($IPIP_DATA, ($iPos), 1)&_BinaryMid($IPIP_DATA, ($iPos + 1), 1)&_BinaryMid($IPIP_DATA, ($iPos + 2), 1)&_BinaryMid($IPIP_DATA, ($iPos + 3), 1))

		If $iIP < $iPrefix Then
			$iHigh = $iMid - 1
		ElseIf $iIP > $iSuffix Then
			$iLow = $iMid + 1
		Else
			$iOffset = _HexToDecimal(_BinaryMid($IPIP_DATA, ($iPos + 6), 1)&_BinaryMid($IPIP_DATA, ($iPos + 5), 1)&_BinaryMid($IPIP_DATA, ($iPos + 4), 1))
			$iLength = _HexToDecimal(_BinaryMid($IPIP_DATA, ($iPos + 7), 1)&_BinaryMid($IPIP_DATA, ($iPos + 8), 1))
			$iPos = $iOffset - 262144 + $iIndexSize
			$sData = BinaryToString(_HexRead($IPIP_DATA, $iPos, $iLength), 4)
			Return StringSplit($sData, @TAB, 2)
		EndIf
	WEnd
EndFunc ;==>FindIP

Func _BinaryMid($FilePath, $Offset, $Length, $Method = "byte")
	Return StringTrimLeft(_HexRead($FilePath, $Offset, $Length, $Method), 2)
EndFunc ;==>_BinaryMid

Func _ip2long($IP)
	$aSplit = StringSplit($IP, '.')
	If $aSplit[0] < 4 Then Return -1
	Return ($aSplit[1] * 16777216) + ($aSplit[2] * 65536) + ($aSplit[3] * 256) + ($aSplit[4] * 1)
EndFunc ;==>_ip2long

Func _HexToDecimal($hx_hex)
	If StringLeft($hx_hex, 2) = "0x" Then $hx_hex = StringMid($hx_hex, 3)
	If StringIsXDigit($hx_hex) = 0 Then Return SetError(1, @error, 0)
	Local $ret="", $hx_count=0, $hx_array = StringSplit($hx_hex, ""), $Ii, $hx_tmp
	For $Ii = $hx_array[0] To 1 Step -1
		$hx_tmp = StringInStr($HX_REF, $hx_array[$Ii]) - 1
		$ret += $hx_tmp * 16 ^ $hx_count
		$hx_count += 1
	Next
	Return $ret
EndFunc ;==>_HexToDecimal

Func _HexRead($FilePath, $Offset, $Length)
	Local $Buffer, $ptr, $fLen, $hFile, $Result, $Read, $err, $Pos

	If Not FileExists($FilePath) Then Return SetError(1, @error, 0)
	$fLen = FileGetSize($FilePath)
	If $Offset > $fLen Then Return SetError(2, @error, 0)
	If $fLen < $Offset + $Length Then Return SetError(3, @error, 0)

	$Buffer = DllStructCreate("byte[" & $Length & "]")
	$ptr = DllStructGetPtr($Buffer)

	$hFile = _WinAPI_CreateFile($FilePath, 2, 2, 0)
	If $hFile = 0 Then Return SetError(5, @error, 0)

	$Pos = $Offset
	$Result = _WinAPI_SetFilePointer($hFile, $Pos)
	$err = @error
	If $Result = 0xFFFFFFFF Then
		_WinAPI_CloseHandle($hFile)
		Return SetError(6, $err, 0)
	EndIf

	$Read = 0
	$Result = _WinAPI_ReadFile($hFile, $ptr, $Length, $Read)
	$err = @error
	If Not $Result Then
		_WinAPI_CloseHandle($hFile)
		Return SetError(7, $err, 0)
	EndIf

	_WinAPI_CloseHandle($hFile)
	 If Not $Result Then Return SetError(8, @error, 0)

	$Result = DllStructGetData($Buffer, 1)

	Return $Result
EndFunc ;==>_HexRead
