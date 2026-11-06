#!/usr/bin/env bash

echo "=== [Cloudix] Starting Automated Desktop & Audio Services ==="

# 1. Kill any stale processes cleanly
pkill -f x11vnc 2>/dev/null || true
pkill -f websockify 2>/dev/null || true
pkill -f Xvfb 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true
pkill -f audio_streamer.py 2>/dev/null || true
sudo nginx -s stop 2>/dev/null || true

# 2. Start virtual display Xvfb
export DISPLAY=:1
Xvfb :1 -screen 0 1280x720x24 &
sleep 2

# 3. Start PulseAudio Virtual Sound Card
pulseaudio -D --exit-idle-time=-1 2>/dev/null || true
sleep 1
pactl load-module module-null-sink sink_name=Speaker sink_properties=device.description="Speaker" 2>/dev/null || true
pactl set-default-sink Speaker 2>/dev/null || true

# 4. Start XFCE Desktop session with compositing disabled (zero lag)
dbus-launch xfce4-session &
sleep 2
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true

# 5. Start high-performance VNC server on port 5900
x11vnc -display :1 -rfbport 5900 -nopw -forever -shared -repeat -nowf &
sleep 2

# 6. Start Real-time Audio Streamer on port 6081
python3 .devcontainer/audio_streamer.py > /tmp/audio_streamer.log 2>&1 &
sleep 1

# 7. Start Websockify and Unified Nginx Proxy on port 6080
if command -v nginx >/dev/null 2>&1; then
    websockify 6082 localhost:5900 &
    sudo nginx -c "$(pwd)/.devcontainer/nginx.conf" 2>/dev/null || nginx -c "$(pwd)/.devcontainer/nginx.conf" 2>/dev/null || true
else
    websockify --web=/usr/share/novnc 6080 localhost:5900 &
fi
sleep 2

# 8. Start Cloudflare Tunnel in background and log live URL
CF_BIN=$(which cloudflared 2>/dev/null || true)
if [ -z "$CF_BIN" ]; then
    if [ -x "/usr/local/bin/cloudflared" ]; then
        CF_BIN="/usr/local/bin/cloudflared"
    elif [ -x "./cloudflared" ]; then
        CF_BIN="./cloudflared"
    else
        echo "Installing cloudflared binary..."
        sudo curl -sL --output /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
        sudo chmod +x /usr/local/bin/cloudflared
        CF_BIN="/usr/local/bin/cloudflared"
    fi
fi

nohup "$CF_BIN" tunnel --url http://localhost:6080 > /tmp/cloudflared.log 2>&1 &

echo "Waiting for Cloudflare Tunnel URL..."
TUNNEL_URL=""
for i in {1..15}; do
    if [ -f /tmp/cloudflared.log ]; then
        TUNNEL_URL=$(grep -o "https://[a-zA-Z0-9-]*\.trycloudflare\.com" /tmp/cloudflared.log | tail -n 1)
        if [ -n "$TUNNEL_URL" ]; then
            break
        fi
    fi
    sleep 1
done

# 9. Print status & live tunnel URL
echo "=========================================================="
echo "🎉 Cloudix Linux Desktop + Audio is LIVE!"
echo "Port: 6080 forwarded (Screen + Sound in 1 Tunnel)"
if [ -n "$TUNNEL_URL" ]; then
    echo "🌐 Public Link: ${TUNNEL_URL}/vnc.html?autoconnect=true&resize=scale"
    echo "🔊 Live Audio:  ${TUNNEL_URL}/audio"
else
    echo "⚠️ Tunnel starting, check with: cat /tmp/cloudflared.log"
fi
echo "=========================================================="
