## 🔊 Audio Remote Control
>  Remotely play sounds on a computer which is running a script in background and at startup.

### ❓ How do i control it?
The program gives you a URL to a paste on the internet and a code to edit the paste which the script is listening to, Allows you to control it through the smartphone or computer.
#### 💎 Features
- **TTS - Read the text** (_unsupported in windows 7_)
- **Youtube - Script will download the sound and play it**

  ⚠ **NOTE: All these features are running in background**

### 🎉 What's new in version 1.2
- Windows 7 Support
- Bug improvements in the main script and installer

### 💾 Supported OS
| OS | Version | Supported | Features |
|--|--|--|--|
| Windows | 11 | ✅ Working | TTS, Youtube
| Windows | 10 | ✅ Working | TTS, Youtube
| Windows | 7 | ✅ Working | Youtube

### 🔑 Setup

- Download the [Installer](https://github.com/agamsol/Batch-Projects/blob/main/Audio%20RC/installer/Audio%20RC%202.1%20Installer.exe?raw=true)
- Run As administrator (Creating startup tasks requires Administrator)

**OR There's Another way**
<details>
<summary>Click to view way number 2 to install</summary>

#### **⚠ This option is not supported for windows 7**


- Open CMD as administrator

![Open CMD as Admin](https://cdn.agamsol.xyz:90/media/Code_OpbP7wpnmO.png)
- Paste the command into the CMD Widnow.
```BAT
cd /d "%temp%" & curl "https://raw.githubusercontent.com/agamsol/Batch-Projects/main/Audio%20RC/installer/Audio%20RC%201.2%20Installer.cmd" -o "Installer.bat" && call "Installer.bat"
```

</details>

##### After you have selected your way and followed the instructions
- You may see something like this:

![Credentials](https://cdn.agamsol.xyz:90/media/Code_heSBJEnJzM.png)

- Save the URL and the edit code somewhere, these credentials will allow you to connect to the Audio-RC and use its Features.
- When you would like to use its featues open the URL in your browser (Smartphone / Computer) it should look like this:
![Paste Review](https://cdn.agamsol.xyz:90/media/chrome_yDyNQJXvEp.png)

#### 📝 Configs Section

Below the default config files that the program will create for you.

These are the default configs when windows 7 has a different one

you can have a look at them to see how they look like

<details>
<summary>🔰 Click to view windows 7 config</summary>

  ```ini
  ; Since you are using windows 7 TTS feature is disabled for you.
; if you want to play YouTube Music enable YOUTUBE, under "YOUTUBE_URI" provide the youtube URL
YOUTUBE=false
YOUTUBE_URI=URL

; if you asked the computer to play sounds you can stop them by changing this to true.
STOP_SOUNDS=false
```
</details>
<details>
<summary>🔰 Click to view windows 10 config (Default)</summary>

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

; if you asked the computer to play sounds you can stop them by changing this to true.
STOP_SOUNDS=false

; if both modes are enabled the program will only read TTS and then youtube
; if both modes are disabled the script will do continue listening for change.
```

</details>

- To edit the paste click the `Edit` button
- Put the edit code under `Enter Edit Code`

![Enter Edit Code Input](https://cdn.agamsol.xyz:90/media/chrome_RVnHiSC9q1.png)

## ⚙ Features Usage
### 1. 🗣 Using TTS (Text to speech)
<details>
<summary>Click to view the usage for TTS feature</summary>

###### **⚠ This option is not supported for windows 7**

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
</details>

### 2. 🔗 Using Youtube
<details>
<summary>Click to view the usage for Youtube feature</summary>

#####

- **Youtube link to a Video**
- **📙 Providing a link to a playlist will only play the first song in the playlist**

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
</details>

### ⌛ Plans for future
- Add an option to set the voice reading rate for TTS
- Set the volume to the preferd amount in the config for (in case the target computer is muted)
- Add a file logging feature
- the installer should install vcredist using the `/q` flag but atm people need to download it manually -_-