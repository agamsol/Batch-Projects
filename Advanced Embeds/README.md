## 📨 Advanced Embeds Version 1.0 (BETA)
> Allow a batch script to send discord messages to a webhook.

> 🔓 Open Source & Free for use

- **Checks the webhook you provide**
- **Send Messages, Embeds and files**
- **Ability to edit messages**
- **Custom Emojis in messages and embeds**

#### How to use:
- First - manually generate hardcoded JSON file, [discord.club](https://discord.club/dashboard) is highly recommended for generating the embed configuration

- once you generated the JSON you need to upload the content to a website which can provide raw URL such as: [pastebin](https://pastebin.com/), [rentry](https://rentry.co) or even [github](https://github.com/). once you have it uploaded make sure to have the raw link for it.

- Once we have the raw URL saved somewhere we can take a look at the valid program parameters table

| Parameter      | Description |
| ------------------- | ------- |
| `--help`  | Display an help message which has all valid parameters |
| `--webhook "<Webhook>"` | The webhook where the messages will be sent |
| `--current-timestamp` | The current timestamp for embed message |
| `--attach-files "<Amount>:<Variable Name>"` | Files to attach to the discord messages. _(remember the 8MB limit)_|
| `--replace "<Find String>:<Variable Name>"` | Replace a String in the message Configuration. |
| `--URL "<RAW-URL>"` | The URL for the message configuration. **HAS TO BE RAW DATA**, if this is not defined by you the program will see if you requested to send files only. |
| `--raw-check false` | this option is set to `true` by default, the URL validator system has a RAW system validator. to disable it you need this flag. |
| `--edit-message "<Message ID>"` | Edit a message instead of sending another one. if the message does not exist the program will exit the process. this can be bypassed using the `--force` flag which will send the message if it wasn't found |
| `--delete-message "<Message ID>"` | Delete Messages that the webhook sent, This option requires to set webhook in each of the ways. |
- **`--attach-files` Usage**
<details>
  <summary>Click this for more information</summary>
  
Heres a quick example:

```bat
set "Attachment[1]=dog.jpg"
```

**Example Flag Which matches the above `--attach-files "1:Attachment"`**
- Why is the number 1 in there?
Because we have 1 attachment, the number is 1

##### ⚠️ NOTE: if we want another attachment we can use `set "Attachment[2]=cat.jpg"` (and for the flag we will use `--attach-files "2:Attachment"` as we will have 2 attachments)
- Why is the Word Attachment
We want the variable name to be `Attachment` so we let the program know about that
</details>

- **`--replace` Usage**
<details>
  <summary>Click this for more information</summary>
  
Heres a quick example:

```bat
set "ReplaceConfiguration[1]=ReplaceMe:WithThis"
```
##### the string `ReplaceMe` will be replaced with `WithThis`

**Example Flag Which matches the above `--replace "1:ReplaceConfiguration"`**
- Why is the number 1 in there?
Because we have 1 string to replace.

##### ⚠️ NOTE: if we want another string replacement we can use `set "ReplaceConfiguration[2]=$Age$:17"` (also chnage the flag to `--replace "2:ReplaceConfiguration"`) as there are 2 string replacements

We want the variable name to be `ReplaceConfiguration` so we let the program know about that
</details>

###### ⚠️ NOTE: The order of the parameters is not matter.

- Once we have looked at the valid parameters we now can start sending messages to discord using webhooks.

- You can use this [tutorial](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) to create a webhook.

#### General Usage:
- Copy the location of where `index.bat` is stored
- Open 'CMD' and use the `cd` command to change the current directory,
- I will do `cd "c:\users\%username%\desktop\Advanced Embeds\"`

Once you have done that you will be able to use parameters

- for example (Command Prompt): `index.bat --help`
- In this case `--help` is the parameter

### Teaching Advanced Embeds the webhook
There are 2 methods to teach the program your webhook link

**WAY NUMBER 1**
- Using the parameter `--webhook`

**EXAMPLE**
```bat
index.bat --webhook "https://discord.com/api/webhooks/917431448745689109/jC24lToGveERw7kLeImbEk4WygiWA17_lYDSzMJUBYR6MnW0wdHNwfDSS26z2TAF7eao"
```
- The command above will know the webhook _**only for 1 time**_

##### ⚠️ **NOTE: THE WEBHOOK WILL ONLY BE KNOWN IN THE TIME WHERE YOU SENT THE COMMAND**

**WAY NUMBER 2**
**This way has to be done only 1 time**
- type in the current CMD window 
```bat
set "Webhook=<My webhook>"
```

**EXAMPLE**

```bat
set "webhook=https://discord.com/api/webhooks/917431448745689109/jC24lToGveERw7kLeImbEk4WygiWA17_lYDSzMJUBYR6MnW0wdHNwfDSS26z2TAF7eao"
```

- After entering the command the webhook is now set and it will be removed once you will close the CMD window.

### Sending Messages
- For this example we will be sending a simple message just for the showcase

I generated a JSON for a simple message
```json
{
  "username": "A Name",
  "content": "Some Cool Message\n\nSent from Advanced Embeds",
  "embeds": [],
  "components": []
}
```
- I also uploaded it to [pastebin](https://pastebin.com/), to see how it looks [pastebin.com/raw/nMPHJa5M
](https://pastebin.com/raw/nMPHJa5M)

- Now we want to send the message
- We specified the webhook using the `set` comamnd
- Now we want to speficy the message configuration, We will do
```bat
index.bat --URL "https://pastebin.com/raw/nMPHJa5M"
```

- Having a look we can see that the message was sent to the webhook
```Microsoft Windows [Version 10.0.22000.318]
(c) Microsoft Corporation. All rights reserved.

C:\Users\Agam\Desktop\Programs\Advanced Embeds>set "webhook=https://discord.com/api/webhooks/917437944749506580/b3KqCgcFfxXbUudYjVS5dW_lkb8XuXPJFxDVjt5SaB-lsQwYI_MQ2C9HlLjCpx08KKfF"

C:\Users\Agam\Desktop\Programs\Advanced Embeds>index.bat --URL "https://pastebin.com/raw/nMPHJa5M"
Message Successfully Sent: 917438282139303977
Text to Speech: OFF

C:\Users\Agam\Desktop\Programs\Advanced Embeds>
```

![Message Review](https://imgur.com/phbjgDz.png)

- You can repeat the same process with different JSON templates

### Sending Files to the webhook
##### ⚠️ NOTE: YOU CANT SEND FILES HIGHER THAN 8MB

- Make sure you have files that you will be able to send
- Put the files in the current directory or speficy full paths instead

- I now have 2 files, Their names are: `dog.jpg` and `file.txt`

- I will be showing you how you can send 1 of them and both of them

##### ⚠️ NOTE: IF WE WANT WE CAN ALSO ADD MESSAGE CONFIGURATION USING THE `--URL "<RAW-URL>"` PARAMETER

#### Lets send 1 file to the webhook
- We will be selecting to upload `dog.jpg`
- Our command should look like this if we want to upload the file
```
index.bat --attach-files "dog.jpg"
```

- After entering this command you will see that the image was sent:

![Dog Image](https://imgur.com/JVLtsrP.png)

- Alright, We uploaded 1 file but what if we want more?

- Now we will upload both files

- the command we would need to use would look like this:
```
index.bat --attach-files ""dog.jpg" "file.txt""
```

- We can see at the webhook in discord that we recived both files
![All Files](https://imgur.com/3jM4l9w.png)

### Edit Messages
- To Edit the message you need the message ID

- We will be editing a normal message with the ID `917444463234801664`

- To edit the message we would like to use the `--edit-message` flag

##### NOTE: our command should contain the new content or files, just as if we were sending it as new message

- I uploaded the updated configuration to [pastebin.com/raw/LXccciVX](https://pastebin.com/raw/LXccciVX)
- We would use the command
```
index.bat --edit-message "917446243054141480" --URL "https://pastebin.com/raw/LXccciVX"
```

- After entering the command we will see that the message has been edited. (GIF Below)
![Edit Message Gif](https://imgur.com/nq6YCB0.gif)

### ❓ Support
if you need help feel free to DM me in discord, `Agam#0001`
Or you can join my discord server here:
> <a href="https://discord.gg/CnqSFMD9zK" rel="Discord Server">![Server](https://img.shields.io/discord/898195508231802931.svg?label=Discord&amp;colorB=7289DA)</a>

##### You better join my discord server instead as i dont accept friend requests