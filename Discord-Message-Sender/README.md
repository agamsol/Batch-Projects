## 🎮 Discord Message Open Source 2.0
> Send Discord messages to webhooks without limitations.

> Send Embeds, Messages, Files using Command prompt.

- **💰 A Free to use open source**

## ❓ Usage
1. Open CMD and CD to the path where `source.bat` is located.
   (you can use `cd /d "path"`)

#### 🔗 Setting the webhook
- Create your [webhook URL](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).
- Type on the cmd window `set "webhook=<WEBHOOK_url_HERE>"`

#### 🧯 Silent Mode Selection
- Commands Other than `--command` flag Require silent mode specification.

##### Silent Mode Selection:

`call source.bat -silent` - **output mode**

`call source.bat +silent` - **silent mode**

###### ⚠ NOTE: For the Tutorial we will be using output mode for our commands.

#### 📩 Sending simple Message
##### Command:
`call source.bat -silent --message "Hello\\nWorld"`
##### Expected discord result:
![Image](https://i.imgur.com/0vGMTlh.png)

#### 📨 Sending Embed Message
- **Select your color code in hex format, I usually use [hexcolortool.com](https://www.hexcolortool.com/), Great color Selector.** 
##### Usage Template
`call source.bat -silent --embed "<title>" "<message> "<#HexColor>" "<ImageURL (optional)>"`

##### For the tutorial we will be using the color <span style="color: #fb8074">#fb8074</span>

##### Command:
`call source.bat -silent --embed "A Nice Title" "A Nice message body\\nto display in the embed" "fb8074" "https://i.imgur.com/XwxUKJw.png"`

##### Expected discord result
![Image](https://i.imgur.com/BxEY4XI.png)

> #### More Information can be found using the command `call source.bat --command help`

## 💬 Any other Questions?
> **Feel Free to join my Discord Server for support**

><a href="https://discord.gg/GFvXSwZ" rel="Discord Server">![Server](https://img.shields.io/discord/847289537566474250.svg?label=Discord&amp;colorB=7289DA)</a>
