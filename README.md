# 🚀 Cloud Android Emulator (Redroid + Google Play Store)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/aproxxpc/cloudix-gaming)
![Android 11](https://img.shields.io/badge/Android-11.0%20(GApps)-brightgreen?logo=android)
![Web Streaming](https://img.shields.io/badge/Stream-ws--scrcpy-blue?logo=googlechrome)
![Cloud](https://img.shields.io/badge/Platform-GitHub%20Codespaces-purple?logo=github)
![Cost](https://img.shields.io/badge/Cost-100%25%20Free-orange)

A **zero-configuration, 1-click Cloud Android Emulator** running inside **GitHub Codespaces** (4 vCPUs, 16GB RAM). Stream high-performance Android 11 directly to any web browser on PC or Mobile using `ws-scrcpy`—no heavy local software like BlueStacks or LDPlayer required!

---

## ✨ Features

- 🤖 **Android 11 with Google Play Store**: Pre-packaged with Open GApps (`abingcbc/redroid:11.0.0-gapps`) so you can download apps and games directly from Google Play.
- ⚡ **Zero Local Installation**: Runs 100% in the cloud on GitHub's free infrastructure. Works even on low-end laptops, chromebooks, or budget phones.
- 🌐 **Instant Browser Access**: Port `8000` automatically forwards as a public web link. No VNC clients or third-party viewers needed.
- 🎮 **Touch, Mouse & Keyboard Support**: Full interactive controls with smooth guest GPU mode at 1280x720 resolution.
- 💾 **Persistent Data**: Includes Docker volume storage (`redroid-data`) so your downloaded apps and settings persist across restarts.
- 📱 **Cross-Platform**: Seamless experience on desktop browsers (Chrome, Edge, Firefox) and mobile browsers (Chrome for Android, Safari for iOS).

---

## 🚀 Quick Start Guide

### Step 1: Launch Codespace
Click the badge below to start your private cloud emulator:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/aproxxpc/cloudix-gaming)

### Step 2: Wait for Automatic Setup
1. GitHub Codespaces will build the environment and start the Docker containers automatically.
2. The `postStartCommand` initializes kernel binder support, starts Android 11, and connects `ws-scrcpy`.
3. In approximately 2–3 minutes, Codespaces will automatically open port `8000` in a new browser tab.
   > *Note: If it does not auto-open, switch to the **Ports** tab in the bottom panel of VS Code, right-click on **Port 8000**, and select **Open in Browser**.*

### Step 3: Stream Android in Your Browser
1. In the `ws-scrcpy` web interface, you will see your connected Android device (`redroid:5555`).
2. Click on **Broadway.js** or **H264 Converter** (or **Tiny H264**) next to the device name.
3. Your live Android 11 screen will stream in real time!

---

## 📱 Mobile Browser Usage

To use this Cloud Android Emulator on your smartphone:
1. Open your Codespace Port 8000 URL in **Google Chrome** (Android) or **Safari** (iOS).
2. Rotate your phone to **Landscape Mode** to match the 1280x720 screen aspect ratio.
3. Use Chrome's menu (`⋮`) and tap **Add to Home screen** or **Install app** for a full-screen, borderless native phone experience!

---

## 📦 Installing Apps & Games

### Method 1: Google Play Store
1. Open the **Play Store** app inside the stream.
2. Sign in with your Google account.
3. Search and download any compatible app or game.

### Method 2: Sideload via ADB (from Codespaces Terminal)
You can directly download and install APKs via the VS Code terminal:
```bash
# Connect to ADB
adb connect 127.0.0.1:5555

# Download any APK
wget -O app.apk "https://example.com/app.apk"

# Install the APK into Android
adb install app.apk
```

---

## 🛠️ Management & Troubleshooting

| Action | Command (in VS Code Terminal) |
|---|---|
| **View Android Logs** | `docker logs -f redroid` |
| **View Web Stream Logs** | `docker logs -f ws-scrcpy` |
| **Reconnect ADB** | `docker exec ws-scrcpy adb connect redroid:5555` |
| **Restart Emulator** | `docker restart redroid ws-scrcpy` |
| **Re-run Setup Script** | `bash .devcontainer/start.sh` |

---

## 📜 Credits & Acknowledgements

- **[Redroid (Remote Android)](https://github.com/remote-android/redroid-doc)** — Android in Docker container solution.
- **[abingcbc/redroid](https://hub.docker.com/r/abingcbc/redroid)** — Redroid build with pre-integrated Google Apps (GApps).
- **[ws-scrcpy](https://github.com/NetrisTV/ws-scrcpy)** — Web-based client for scrcpy screen mirroring.
- **[GitHub Codespaces](https://github.com/features/codespaces)** — Cloud developer environments.
