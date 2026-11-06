#!/usr/bin/env bash

echo "=== [Cloudix] Updating Desktop Shortcuts ==="

# Target desktop folder (both ~/Desktop and /home/codespace/Desktop)
TARGET_DIRS=()
if [ -d "${HOME}/Desktop" ] || [ -d "${HOME}" ]; then
    mkdir -p "${HOME}/Desktop"
    TARGET_DIRS+=("${HOME}/Desktop")
fi
if [ -d "/home/codespace/Desktop" ] || [ -d "/home/codespace" ]; then
    mkdir -p "/home/codespace/Desktop"
    TARGET_DIRS+=("/home/codespace/Desktop")
fi

for DESK in "${TARGET_DIRS[@]}"; do
    echo "Configuring icons in: $DESK"

    # 1. Google Chrome
    cat << 'EOF' > "$DESK/google-chrome.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Comment=Access the Internet
Exec=/usr/bin/google-chrome-stable --no-sandbox %U
Icon=google-chrome
Terminal=false
StartupNotify=false
Categories=Network;WebBrowser;
EOF

    # 2. Google Antigravity
    cat << 'EOF' > "$DESK/Google_Antigravity.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Antigravity
Comment=Google Antigravity AI Studio
Exec=/usr/local/bin/anti
Icon=system-run
Terminal=false
StartupNotify=false
Categories=Development;
EOF

    # 3. VS Code
    cat << 'EOF' > "$DESK/code.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Visual Studio Code
Comment=Code Editing. Redefined.
Exec=/usr/share/code/code --no-sandbox --unity-launch %F
Icon=vscode
Terminal=false
StartupNotify=false
Categories=Development;IDE;
EOF

    # 4. Terminal
    cat << 'EOF' > "$DESK/xfce4-terminal.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal Emulator
Comment=Use the command line
Exec=xfce4-terminal
Icon=org.xfce.terminal
Terminal=false
StartupNotify=false
Categories=System;TerminalEmulator;
EOF

    # 5. File Manager (Thunar)
    cat << 'EOF' > "$DESK/thunar.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=Browse the file system
Exec=thunar %F
Icon=org.xfce.thunar
Terminal=false
StartupNotify=false
Categories=System;FileManager;
EOF

    # 6. Task Manager (RAM & CPU Monitor)
    cat << 'EOF' > "$DESK/xfce4-taskmanager.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Task Manager
Comment=Easy to use task manager
Exec=xfce4-taskmanager
Icon=org.xfce.taskmanager
Terminal=false
StartupNotify=false
Categories=System;
EOF

    # Remove Web Games shortcut
    rm -f "$DESK/web_games.desktop"

    # 7. Godot Engine (2D & 3D Game Maker)
    cat << 'EOF' > "$DESK/godot.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Godot (2D & 3D Game Maker)
Comment=Free and open source 2D and 3D game engine
Exec=/usr/local/bin/godot
Icon=godot
Terminal=false
StartupNotify=false
Categories=Development;IDE;
EOF

    # 8. Instant Backup
    cat << 'EOF' > "$DESK/backup.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Instant Backup
Comment=Backup your workspace files
Exec=/bin/bash -c "tar -czf /workspaces/Cloudix/backup-$(date +%Y%m%d).tar.gz /workspaces/Cloudix 2>/dev/null && notify-send 'Cloudix' 'Workspace backup created!'"
Icon=document-save
Terminal=false
StartupNotify=false
Categories=Utility;
EOF

    chmod +x "$DESK"/*.desktop
    gio set "$DESK"/*.desktop metadata::trusted true 2>/dev/null || true
done

# Force XFCE Desktop to instantly start / reload icons
export DISPLAY=:1
nohup xfdesktop >/dev/null 2>&1 &
sleep 1
xfdesktop --reload 2>/dev/null || true

echo "=========================================================="
echo "🎉 ALL DESKTOP SHORTCUTS SUCCESSFULLY CREATED & RELOADED!"
echo "=========================================================="
