### ⚙️ Batch Json Parser v1.0
> Easily parse json FILE / URL by using command line parameters

- Infinite parameter support _(Parse more than 1 key in a request)_

- Small script which can be used as a label or as a file

### 👤 Usage
- Open Command Prompt
- Make sure you are in the same directory as `JsonParse.bat`
- `call :JsonParse [...]` JsonParse also can accept arguments by being called via a label
- `call JsonParse.bat "RAW-URL / FILE" "JsonKey1" "JsonKey2"`

**Command Explanation**
- **RAW-URL** : Direct raw Link to the json file
- **FILE** : `Fully qualified / filename` path to the json file which will be parsed

- **JsonKey1** A key which has a value and can be parsed off of the json FILE / URL

- **JsonKey2** Some other key to parse off of the json

- **OtherKey** Some other keys.. end so on if you want to add more keys to parse


### 🍾 Json Example

```json
{
    "Name": "Agam",
    "Age": 17,
    "setup": {
        "keyboard": "Huntsman",
        "mouse": "Basilisk Ultimate"
    },
    "Phone": {
        "type": "iPhone",
        "version": "iOS 15.0",
        "model": "13 Pro Max"
    }
}
```

##### All values
- **Name** - Agam
- **Age** - 17
- **setup.keyboard** - Huntsman
- **setup.mouse** - Basilisk Ultimate
- **Phone.type** - iPhone
- **Phone.version** - iOS 15.0
- **Phone.model** - 13 Pro Max