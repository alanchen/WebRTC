# WebRTC iOS 預編譯框架
[![Latest version](https://img.shields.io/github/v/release/alanchen/WebRTC)](https://github.com/alanchen/WebRTC/releases)
[![Release Date](https://img.shields.io/github/release-date/alanchen/WebRTC)](https://github.com/alanchen/WebRTC/releases)
[![Total Downloads](https://img.shields.io/github/downloads/alanchen/WebRTC/total)](https://github.com/alanchen/WebRTC/releases)

本 repo 提供 WebRTC 的 iOS 預編譯二進位框架（xcframework 格式），透過 GitHub Actions 自動建置與發佈。

原始專案 [stasel/WebRTC](https://github.com/stasel/WebRTC) 已停止維護（最後版本為 M141），本 repo 延續其建置流程，持續追蹤 Google WebRTC 最新穩定版本。

## 自動建置機制

- 每月 15 號自動執行，也可手動觸發
- 自動查詢 [Chromium Dashboard](https://chromiumdash.appspot.com/branches) 取得最新穩定版本
- 跳過中間版本，直接建置當前最新穩定版
- 從官方 WebRTC [原始碼](https://webrtc.googlesource.com/src/)編譯，不做任何修改
- 建置完成後自動建立 GitHub Release 並提交 PR

## 支援平台

| **平台 / 架構** | arm64  | x86_64 |
|-----------------|--------|--------|
| **iOS (實機)**   |   O   |  N/A   |
| **iOS (模擬器)** |   O   |   O   |

## 系統需求

- iOS 12+

## 安裝方式

### Swift Package Manager

在 Xcode 中選擇 File > Swift Packages > Add Package Dependency，輸入本 repo 的 URL。

或在 `Package.swift` 中加入：
```swift
dependencies: [
    .package(url: "https://github.com/alanchen/WebRTC.git", .upToNextMajor("147.0.0"))
]
```

使用 `latest` 分支取得最新版本：
```swift
dependencies: [
    .package(url: "https://github.com/alanchen/WebRTC.git", branch: "latest")
]
```

### 手動安裝
1. 從 [Releases](https://github.com/alanchen/WebRTC/releases) 下載 xcframework zip
2. 解壓縮
3. 將 xcframework 加入專案的 Embedded Frameworks

## 使用方式

```swift
import WebRTC
```

WebRTC iOS demo app 可參考：https://github.com/stasel/WebRTC-iOS

## 自行編譯

如需自行編譯 WebRTC，請參考官方指南：
https://webrtc.googlesource.com/src/+/refs/heads/main/docs/native-code/ios/README.md

也可以參考本 repo 的 [build script](scripts/build.sh)。

## 授權條款

- BSD 3-Clause License
- WebRTC License: https://webrtc.org/support/license
