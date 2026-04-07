import asyncio
from playwright.async_api import async_playwright
import os
import http.server
import socketserver
import threading
import time

def run_server():
    os.chdir("html")
    handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("", 8000), handler) as httpd:
        httpd.serve_forever()

async def capture():
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    # Wait for server to start
    time.sleep(2)

    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={'width': 1280, 'height': 720})
        await page.goto("http://localhost:8000")
        await asyncio.sleep(5)  # Wait for assets and shaders to load
        await page.screenshot(path="../verification/industrial_vibe.png")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(capture())
