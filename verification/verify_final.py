import os
from playwright.sync_api import sync_playwright

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)

        # Pixel 5
        context = browser.new_context(
            **p.devices["Pixel 5"]
        )
        page = context.new_page()
        page.goto(f"file://{os.getcwd()}/index.html")
        page.wait_for_timeout(2000)
        page.screenshot(path="verification/final_mobile.png")

        # Desktop
        page_desktop = browser.new_page(viewport={"width": 1280, "height": 800})
        page_desktop.goto(f"file://{os.getcwd()}/index.html")
        page_desktop.wait_for_timeout(2000)
        page_desktop.screenshot(path="verification/final_desktop.png")

        browser.close()

if __name__ == "__main__":
    run_verification()
