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

    time.sleep(2)

    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={'width': 1280, 'height': 720})

        # Log console messages
        page.on("console", lambda msg: print(f"CONSOLE: {msg.text}"))
        page.on("pageerror", lambda exc: print(f"PAGE ERROR: {exc}"))

        await page.goto("http://localhost:8000")
        # Increase wait time for assets and env map
        await asyncio.sleep(10)
        await page.screenshot(path="../verification/industrial_vibe_debug.png")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(capture())
