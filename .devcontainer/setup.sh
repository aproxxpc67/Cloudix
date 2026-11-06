#!/usr/bin/env bash

echo "=== [Cloudix] Starting Automated Environment Setup ==="

# 1. Update and install GUI base + VNC + utilities + Sound & Nginx
sudo apt-get update -y || true
sudo apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal xfce4-taskmanager \
    xvfb x11vnc novnc websockify \
    dbus-x11 xarchiver file-roller \
    curl wget git python3-pip python3-venv \
    pulseaudio pulseaudio-utils ffmpeg nginx \
    htop || true

# 2. Install Google Chrome Desktop
if [ ! -f /usr/bin/google-chrome ]; then
    echo "=== [Cloudix] Installing Google Chrome ==="
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt-get install -y /tmp/chrome.deb || sudo apt-get -f install -y
    rm -f /tmp/chrome.deb
fi

# 3. Install Microsoft VS Code Desktop
if [ ! -f /usr/share/code/code ]; then
    echo "=== [Cloudix] Installing VS Code Desktop ==="
    wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O /tmp/code.deb
    sudo apt-get install -y /tmp/code.deb || sudo apt-get -f install -y
    rm -f /tmp/code.deb
fi

# 4. Download and setup Cloudflare tunnel
if [ ! -f /usr/local/bin/cloudflared ]; then
    echo "=== [Cloudix] Installing Cloudflare Tunnel ==="
    sudo curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
    sudo chmod +x /usr/local/bin/cloudflared
fi

# 5. Install Godot Engine (2D & 3D Game Maker)
if [ ! -f /usr/local/bin/godot ]; then
    echo "=== [Cloudix] Installing Godot Engine (2D & 3D Game Maker) ==="
    wget -q https://github.com/godotengine/godot/releases/download/3.5.3-stable/Godot_v3.5.3-stable_x11.64.zip -O /tmp/godot.zip
    unzip -q /tmp/godot.zip -d /tmp/
    sudo mv /tmp/Godot_v3.5.3-stable_x11.64 /usr/local/bin/godot
    sudo chmod +x /usr/local/bin/godot
    rm -f /tmp/godot.zip
fi

# 6. Ensure Task Manager is installed
sudo apt-get install -y xfce4-taskmanager || true

# 5. Create Desktop directory & copy pre-installed shortcuts
DESKTOP_DIR="${HOME}/Desktop"
mkdir -p "$DESKTOP_DIR"

# 1. Google Chrome shortcut with --no-sandbox
if [ -f /usr/share/applications/google-chrome.desktop ]; then
    cp /usr/share/applications/google-chrome.desktop "$DESKTOP_DIR/"
    sed -i 's|/usr/bin/google-chrome-stable|/usr/bin/google-chrome-stable --no-sandbox|g' "$DESKTOP_DIR/google-chrome.desktop"
    echo "StartupNotify=false" >> "$DESKTOP_DIR/google-chrome.desktop"
fi

# 2. Microsoft VS Code shortcut with --no-sandbox
if [ -f /usr/share/applications/code.desktop ]; then
    cp /usr/share/applications/code.desktop "$DESKTOP_DIR/"
    sed -i 's|/usr/share/code/code|/usr/share/code/code --no-sandbox|g' "$DESKTOP_DIR/code.desktop"
    echo "StartupNotify=false" >> "$DESKTOP_DIR/code.desktop"
fi

# 3. Linux Terminal shortcut
cp /usr/share/applications/xfce4-terminal.desktop "$DESKTOP_DIR/" 2>/dev/null || true

# 4. File Manager (Thunar) shortcut
cp /usr/share/applications/thunar.desktop "$DESKTOP_DIR/" 2>/dev/null || true

# 5. Task Manager (RAM & CPU Monitor) shortcut
cp /usr/share/applications/xfce4-taskmanager.desktop "$DESKTOP_DIR/" 2>/dev/null || true

# 6. Setup /usr/local/bin/anti command
sudo tee /usr/local/bin/anti << 'EOF'
#!/bin/bash
export DISPLAY=:1
if [ -f "${HOME}/Downloads/Antigravity-x64/antigravity" ]; then
    nohup "${HOME}/Downloads/Antigravity-x64/antigravity" --no-sandbox --disable-gpu --disable-dev-shm-usage >/dev/null 2>&1 &
    echo "🚀 Antigravity Launched Successfully!"
elif [ -f "/home/codespace/Downloads/Antigravity-x64/antigravity" ]; then
    nohup /home/codespace/Downloads/Antigravity-x64/antigravity --no-sandbox --disable-gpu --disable-dev-shm-usage >/dev/null 2>&1 &
    echo "🚀 Antigravity Launched Successfully!"
else
    echo "Antigravity binary not found in Downloads. Launching Antigravity Web..."
    nohup /usr/bin/google-chrome-stable --no-sandbox https://antigravity.google >/dev/null 2>&1 &
fi
EOF
sudo chmod +x /usr/local/bin/anti

# 7. Setup Google Antigravity launcher
cat << 'EOF' > "$DESKTOP_DIR/Google_Antigravity.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Antigravity
Comment=Google Antigravity AI Studio
Exec=/usr/local/bin/anti
Icon=system-run
Terminal=false
StartupNotify=false
EOF

bash .devcontainer/update_desktop.sh || true

echo "=== [Cloudix] Automated Setup Completed Successfully! ==="
