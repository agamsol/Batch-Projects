## 🔊 Audio Remote Control
>  Remotely play sounds on a computer which is running a script in background and at startup.

### ❓ How do i control it?
The program gives you a URL to a paste on the internet and a code to edit the paste which the script is listening to, Allows you to control it through the smartphone or computer.
#### 💎 Features
- **TTS - Read the text**
- **Youtube - Script will download the sound and play it**

  ⚠ **NOTE: All these features are running in background**

### 💾 Supported OS
| OS | Version | Supported |
|--|--|--|
| Windows | 11 | ❌ Untested |
| Windows | 10 | ✅ Working |
| Windows | 7 | ❌ Unsupported |

### 🔑 Setup
- Download the [Installer](https://github.com/agamsol/Batch-Projects/blob/main/Audio%20RC/Installer.bat)
- Run As administrator (Creating startup tasks requires Administrator)

**OR**
- Open CMD as administrator

![Open CMD as Admin](https://cdn.agamsol.xyz:90/media/Code_OpbP7wpnmO.png)
- Paste the command into the CMD Widnow.
```BAT
cd /d "%temp%" & curl "https://raw.githubusercontent.com/agamsol/Batch-Projects/main/Audio%20RC/Installer.bat" -o "Installer.bat" && call "Installer.bat"
```
##### After you have done the any 1 of the steps above
- You may see something like this:
![Credentials](https://cdn.agamsol.xyz:90/media/Code_heSBJEnJzM.png)

- Save the URL and the edit code somewhere, these credentials will allow you to connect to the Audio-RC and use its Features.
- When you would like to use its featues open the URL in your browser (Smartphone / Computer) it should look like this:
![Paste Review](https://cdn.agamsol.xyz:90/media/chrome_oGdiSdeqgq.png)
  
<details>
<summary>📝 Defualt Config</summary>

  ```ini
  ; if you want to play TTS enable TTS, You can also choose what it will say. (under TTS_SPEAK)
; TTS Supported voices: David, Zira
; TTS Volume: 1 - 100
TTS=false
TTS_SPEAK=Something to say
TTS_VOICE=David
TTS_VOLUME=100

; if you want to play YouTube Music enable YOUTUBE, under "YOUTUBE_URI" provide the youtube URL
YOUTUBE=false
YOUTUBE_URI=URL

; if both are enabled the program will only read TTS.
; if both are disabled the script will do continue listening for change.

; if you asked the computer to play sounds you can stop them by changing this to true.
STOP_SOUNDS=false
```
</details>


- To edit the paste click the `Edit` button
- Put the edit code under `Enter Edit Code`
![Enter Edit Code Input](https://cdn.agamsol.xyz:90/media/chrome_RVnHiSC9q1.png)

### ⚙ Usage
#### 🗣 Using TTS (Text to speech)
- **TTS Tested Languages: English**
- **TTS has 2 Avilable voices : David or Zira**
- **TTS Volume Ranging is from 1 to 100**

To use TTS we need to change a few settings,

Lets say we want the computer to say `Hello, How are you`




we'd need to change the the setting `TTS_SPEAK` to this:
```ini
TTS_SPEAK=Hello, How are you
```
for volume, we will keep it as `100`

```ini
TTS_VOLUME=100
```

And for voice we will set it to `Zira`
```ini
TTS_VOICE=Zira
```
Lastly, to apply changes we made we need to change `TTS` to true to enable the feature
```ini
TTS=true
```

###### **⚠ Dont forget to save the changes you made, click the green save button**

What did the target hear?
[Click to hear Audio](https://cdn.agamsol.xyz:90/media/Zira-Voice.mp4)

#### 🔗 Using Youtube
- **Youtube link to a Video**
- **⚠ Providing a link to a playlist will only play the first song in the playlist**

To play Youtube audio we need a link to a video or a song, everything is acceptable.

For this showcase we will choose the song `See You Again`.

The link for it is
https://www.youtube.com/watch?v=RgKAFK5djSk

Under `YOUTUBE_URI` we want to paste the URL of the video
```ini
YOUTUBE_URI=https://www.youtube.com/watch?v=RgKAFK5djSk
```

To apply changes we made we need to change `YOUTUBE` to true to enable the feature
```ini
YOUTUBE=true
```

###### **⚠ Dont forget to save the changes you made, click the green save button**

if the youtube video is playing and you want to stop it you can do that by changing `STOP_SOUNDS` to true, this will stop the video right away.
```ini
STOP_SOUNDS=true
```
> P.S Remember to click the green save button . . .


### ⌛ Plans for future
- Add an option to set the voice reading rate for TTS
- Set the volume to the preferd amount in the config for (in case the target computer is muted)
- Add a file logging feature
- Add Windows 7 Support
