# TDJSON

> **TeleStats**
>
>If this library makes developing your next Telegram App easier, please download my app [TeleStats](telestats.app). The app shows you fun and interesting statistics about your Telegram Message. All the anlysis and communication with Telegram happens on device using this library!

This repo provides an iOS binary of [tdlib](https://github.com/tdlib/td) and also a `TDJSON.framework` file to directly include include in your iOS project.

> To communicate with `tdlib` you'll have to use `json` function. For a nativ `swift` api use [TDLib-iOS](https://github.com/leoMehlig/TDLib-iOS).
# Installation

### [Carthage](https://github.com/Carthage/Carthage):

Just add `github "leoMehlig/TDJSON"` to your `Cartfile` and do the usual Carthage stuff.

### Manually

You can also download the repo and build the `.xcproj` yourself or go even further and use the `build.sh` script to rebuild [tdlib](https://github.com/tdlib/td).

### Usage

There are direct mappings of the `c++` functions of `tdjson` to `swift`. They can be found in `TDJSON/td_json_client.swift`.

### Version

The version of the *Github Releases* directly maps to the releases of `tdlib`. If a version isn't avaiable please create a issue.
