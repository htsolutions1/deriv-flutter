HTS Bot OAuth Callback Page - Render Deployment Instructions

This folder contains a simple HTML page that handles OAuth callbacks from Deriv.
However, with Render, we'll deploy the ENTIRE Flutter app instead!

WHY RENDER IS BETTER:
- Automatic deployments from Git
- Free SSL/HTTPS
- Simpler configuration
- No need for separate callback page

DEPLOYMENT STEPS:

1. Push your code to GitHub:
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/HTSBot.git
   git push -u origin main

2. Go to Render:
   - Visit https://dashboard.render.com
   - Click "New +" → "Static Site"
   - Connect your GitHub repository
   - Render will auto-detect the render.yaml config

3. Configure:
   - Name: htsbot
   - Branch: main
   - Build Command: flutter build web --release
   - Publish Directory: build/web
   - Click "Create Static Site"

4. Wait for deployment (~3 minutes)
   You'll get a URL like: https://htsbot.onrender.com

5. Update Deriv OAuth App Settings:
   - Go to your Deriv dashboard
   - Update redirect URI to: https://htsbot.onrender.com/callback
   - Save

6. Update Flutter App Configuration:
   - Already done! Check lib/core/config/supabase_config.dart
   - It will use your Render URL

7. Test OAuth Flow:
   - Visit your Render URL
   - Click login
   - Complete OAuth on Deriv
   - You'll be redirected back and logged in!

BENEFITS:
- Every git push automatically deploys
- No localhost issues
- Real HTTPS URL
- Free hosting
- Automatic SSL certificates

That's it! Much simpler than Vercel.

