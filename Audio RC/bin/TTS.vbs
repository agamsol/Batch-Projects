Dim Zira, David

'Args: TTS.vbs <Voice> <Volume> <Speak>'

Set Zira = CreateObject("SAPI.spVoice")
Set Zira.Voice = Zira.GetVoices.Item(1)
Zira.Rate = 2
Zira.Volume = WScript.Arguments(1)

Set David = CreateObject("SAPI.spVoice")
Set David.Voice = David.GetVoices.Item(0)
David.Rate = 2
David.Volume = WScript.Arguments(1)

If WScript.Arguments(0) = "Zira" Then
Zira.Speak WScript.Arguments(2)
End If

If WScript.Arguments(0) = "David" Then
David.Speak WScript.Arguments(2)
End If
