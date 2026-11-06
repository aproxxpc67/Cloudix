#!/usr/bin/env python3
"""
Cloudix Real-Time Low-Latency Audio Streamer
Streams Linux PulseAudio / Desktop sound over HTTP to Web & Mobile clients
"""

import os
import sys
import subprocess
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 6081
FFMPEG_CMD = [
    "ffmpeg",
    "-nostdin",
    "-f", "pulse",
    "-i", "default",
    "-ac", "2",
    "-ar", "44100",
    "-b:a", "96k",
    "-c:a", "libmp3lame",
    "-content_type", "audio/mpeg",
    "-f", "mp3",
    "-"
]

class AudioStreamHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Quiet logging

    def do_HEAD(self):
        self.send_response(200)
        self.send_header("Content-Type", "audio/mpeg")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Connection", "keep-alive")
        self.end_headers()

    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")
            return

        # Stream MP3 audio
        self.send_response(200)
        self.send_header("Content-Type", "audio/mpeg")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Connection", "keep-alive")
        self.end_headers()

        proc = None
        try:
            # Spawn ffmpeg capturing from PulseAudio default sink monitor
            proc = subprocess.Popen(
                FFMPEG_CMD,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                bufsize=1024 * 16
            )
            while True:
                chunk = proc.stdout.read(4096)
                if not chunk:
                    break
                self.wfile.write(chunk)
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            pass
        finally:
            if proc:
                proc.terminate()
                try:
                    proc.wait(timeout=1)
                except Exception:
                    proc.kill()

def main():
    print(f"=== [Cloudix Audio] Starting PulseAudio Streamer on port {PORT} ===")
    server = HTTPServer(("0.0.0.0", PORT), AudioStreamHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == "__main__":
    main()
