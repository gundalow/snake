# Project Plan: Defold Snake (Mobile-First / Linux Dev)

## High-Level Technical Context
* **Engine:** Defold (LUA-based, Message-passing architecture).
* **OS:** Fedora (Linux-native development).
* **Target:** Android (Primary) & HTML5 (Web Preview/Netlify).
* **Graphics:** 2D, Sprite-based, optimized for On-board GPU.
* **Controls:** Touch-swipe gestures.

---

## Milestone: "Yellow World" & Infrastructure
**Goal:** Verify the pipeline from Fedora to Netlify. A "Yellow World" means a successful render loop and a successful CI/CD build.

### Project Initialization
* **Task:** Create a `game.project` file.
* **Requirements:** Set Display width to 720 and height to 1280 (Portrait). Set "High DPI" to true.
* **Approach:** Defining resolution early ensures the AI doesn't calculate coordinates based on a dynamic window, which prevents UI scaling bugs on Android.
* **Verification:** Running the game locally on Fedora shows a window of the correct aspect ratio.

### The "Yellow World" Render
* **Task:** Create a `main.script` and a `main.collection`.
* **Requirements:** Send a `clear_color` message to the `@render` socket with vector4(1, 1, 0, 1).
* **Approach:** In Defold, the background isn't a property; it’s a render command. This verifies the agent understands Defold’s message-passing system.
* **Verification:** The game window is solid yellow.

### Netlify & GitHub Action CI
* **Task:** Create `.github/workflows/build.yml`.
* **Requirements:** Use Java 25, download `bob.jar` using the SHA1 from `info.json`, and bundle for `x86_64-web`. Output to a directory watched by the Netlify GitHub App.
* **Approach:** Automating the build immediately ensures that "vibe coding" doesn't lead to "it works on my machine" syndrome.
* **Verification:** Opening a Pull Request triggers a Netlify "Deploy Preview" link showing the yellow screen.

---

## Milestone: Core Snake Logic & Swipe Controls
**Goal:** A fully playable game loop in the browser.

### Grid-Based Movement
* **Task:** Implement a timer-based movement script (e.g., move every 0.15s).
* **Requirements:** Use a table to store segments. Each "tick," move the head and have segments follow.
* **Approach:** Grid-based movement is easier for AI to debug than continuous physics-based movement. It also performs better on low-end Android hardware.
* **Verification:** The "head" (represented by a square) moves in four directions without stopping.

### Swipe Gesture Detection
* **Task:** Map `touch` input to directions.
* **Requirements:** Capture `action.x/y` on `pressed`, compare to `action.x/y` on `released`. Calculate the angle to determine Up, Down, Left, or Right.
* **Approach:** Swiping is the native "vibe" for mobile. This replaces the need for an ugly on-screen D-pad that takes up screen real estate.
* **Verification:** Swiping on a laptop trackpad or mobile browser changes the snake's direction.

### Food & Growth
* **Task:** Spawn "food" objects at random grid coordinates.
* **Requirements:** Use `factory.create()` to spawn segments when a collision/overlap is detected.
* **Approach:** Using factories is the "Defold way" to manage memory efficiently for many objects.
* **Verification:** Eating food increases the segment count and score.

---

## Milestone: Graphics Polish & APK Generation
**Goal:** Move from "Developer Art" to "Vibe Art" and produce the final Android binary.

### The Visual "Vibe" (Atlas & Shaders)
* **Task:** Create a `.atlas` file and a custom `.fp` (fragment program) shader.
* **Requirements:** Add a "Glow" or "Pulse" effect to the snake head using a simple shader. Use an Atlas for all textures to reduce "Draw Calls."
* **Approach:** On-board graphics struggle with many small textures; an Atlas combines them into one, making the game run at a silky 60FPS on Fedora and Android.
* **Verification:** The snake head pulses visually; the game remains at 60FPS.

### Android Metadata & Export
* **Task:** Configure Android icons, splash screen, and Package ID (e.g., `com.vibe.snake`) in `game.project`.
* **Requirements:** Update the GitHub Action to bundle `armv7-android` or `arm64-android` on merge to `main`.
* **Approach:** Creating the APK on merge ensures you always have a "shippable" version ready for your phone.
* **Verification:** Downloading the APK from the GitHub "Actions" tab and installing it on an Android device works perfectly.

---

## Information needed for Agent Execution:
* **Asset Names:** I will provide `head.png`, `body.png`, and `food.png`.
* **Grid Size:** 20x20.
* **Netlify Folder:** `_build`.
