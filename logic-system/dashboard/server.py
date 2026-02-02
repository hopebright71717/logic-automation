#!/usr/bin/env python3
"""
Logic 儀表板本地伺服器
在 localhost:8888 啟動儀表板
"""

import http.server
import socketserver
from pathlib import Path

PORT = 8888
LOGIC_DIR = Path(__file__).parent.parent  # logic/ 目錄

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(LOGIC_DIR), **kwargs)
    
    def end_headers(self):
        # 允許跨域存取
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
        print("=" * 60)
        print("🚀 Logic 儀表板已啟動！")
        print("=" * 60)
        print(f"\n📊 儀表板網址：http://localhost:{PORT}")
        print(f"📁 服務目錄：{LOGIC_DIR}")
        print(f"\n💡 在 iPad Jump Desktop 中，直接開啟上述網址即可查看")
        print(f"⏱  自動刷新：每 5 秒")
        print(f"\n按 Ctrl+C 停止伺服器\n")
        print("=" * 60)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n👋 儀表板已停止")
