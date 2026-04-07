# VibeSnake 2.5D

A 2.5D Snake game optimized for Android, built with Three.js and Capacitor.

## Project Architecture
- **Framework:** Vanilla JavaScript + Three.js.
- **View:** 2.5D Isometric (Orthographic Camera).
- **Settings:** Move speed = 300ms.
- **Input:** High-sensitivity swipe detection for mobile.
- **Haptics:** Integrated with `@capacitor/haptics`.

## Deployment Instructions

### 1. Initialize GitHub Repo
If you haven't already, initialize a git repository and push to GitHub:
```bash
git init
git add .
git commit -m "Initial commit: VibeSnake 2.5D"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### 2. Link Netlify for Automated "Vibe" Checks
1. Go to [Netlify](https://www.netlify.com/) and log in.
2. Click **"Add new site"** > **"Import an existing project"**.
3. Select **GitHub** and authorize.
4. Select your `VibeSnake` repository.
5. In the build settings:
   - **Build command:** `npm run build`
   - **Publish directory:** `.`
6. To enable the GitHub Action deployment (optional but recommended for CI/CD control):
   - Go to your Site settings in Netlify to find your **Site ID**.
   - Create a **Personal Access Token** in your Netlify User settings.
   - Add `NETLIFY_SITE_ID` and `NETLIFY_AUTH_TOKEN` as secrets in your GitHub repository settings.

### 3. Native Android Build
Once you're happy with the "vibe" on the live URL, run these commands to add the Android platform:
```bash
npm install
npx cap add android
npx cap open android
```
This will open Android Studio, where you can run the app on your physical device or an emulator.

## Development
To run locally:
1. Use a local development server (e.g., `npx serve .`).
2. Open the URL in your browser.
