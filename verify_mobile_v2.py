from playwright.sync_api import sync_playwright
import os
import time

def run():
    with sync_playwright() as p:
        # Use a mobile device descriptor
        iphone_11 = p.devices['Pixel 5']
        browser = p.chromium.launch()
        context = browser.new_context(**iphone_11)
        page = context.new_page()

        # Navigate to the game
        try:
            page.goto('http://localhost:8080', wait_until='networkidle')
        except Exception as e:
            print(f"Error navigating: {e}")
            browser.close()
            return

        # Wait for game to load
        time.sleep(2)

        # Create a directory for screenshots
        os.makedirs('verification', exist_ok=True)

        # 1. Tactical View (Default)
        page.screenshot(path='verification/mobile_tactical_v2.png')
        print("Captured mobile_tactical_v2.png")

        # 2. Click Galaxy Map
        page.click('#btn-galaxy')
        time.sleep(1)
        page.screenshot(path='verification/mobile_galaxy_v2.png')
        print("Captured mobile_galaxy_v2.png")

        # 3. Click Orbit
        page.click('#btn-orbit')
        time.sleep(1)
        page.screenshot(path='verification/mobile_orbit_v2.png')
        print("Captured mobile_orbit_v2.png")

        # 4. Click Comm
        page.click('#btn-comm')
        time.sleep(1)
        page.screenshot(path='verification/mobile_comm_v2.png')
        print("Captured mobile_comm_v2.png")

        browser.close()

if __name__ == "__main__":
    run()
