# Team Streem Adventure Tracker 🏰

A spoiler-free progress dashboard for tracking a secret Minecraft build project.

## Quick Setup (GitHub Pages)

1. **Create a new GitHub repository**
   - Go to github.com → New repository
   - Name it `team-streem` or `adventure-tracker`
   - Make it **Public** (required for free GitHub Pages)
   - Don't initialize with README (we have files already)

2. **Push these files**
   ```bash
   git init
   git add .
   git commit -m "Initial dashboard"
   git branch -M main
   git remote add origin git@github.com:YOUR_USERNAME/team-streem.git
   git push -u origin main
   ```

3. **Enable GitHub Pages**
   - Go to repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: `main` / `/ (root)`
   - Save

4. **Access your dashboard**
   - URL: `https://YOUR_USERNAME.github.io/team-streem/`
   - Wait 1-2 minutes for first deploy

5. **Add to iPads**
   - Open Safari on iPad
   - Go to your GitHub Pages URL
   - Tap Share → Add to Home Screen
   - Name it "Team Streem" or "Adventure Tracker"

## File Structure

```
team-streem-dashboard/
├── index.html      # Main dashboard (all-in-one)
├── data.json       # Data file (update via Make.com or manually)
├── assets/
│   ├── logo.png    # Team Streem logo
│   └── favicon.png # App icon
└── README.md       # This file
```

## Updating Data

### Option 1: Manual Updates
Edit `data.json` directly and push to GitHub. Dashboard auto-refreshes every 60 seconds.

### Option 2: Make.com Automation (Recommended)
Set up a Make.com scenario to:
1. Pull data from Airtable
2. Format as JSON
3. Commit to GitHub via GitHub API

See `MAKE_GITHUB_UPDATE.md` for detailed automation setup.

### Option 3: Direct Airtable API
Edit `index.html` CONFIG section to use Airtable directly:
```javascript
const CONFIG = {
    dataSource: 'airtable',
    airtableApiKey: 'pat_YOUR_READ_ONLY_TOKEN',
    airtableBaseId: 'appYOUR_BASE_ID',
    // ...
};
```

## Data Format

```json
{
  "stats": {
    "blocksPlaced": 4287,
    "blocksTotal": 9747,
    "overallPercent": 44,
    "daysToReveal": 23
  },
  "zones": [
    {
      "name": "Zone Alpha",
      "codename": "Operation Deep",
      "emoji": "🔮",
      "percent": 78,
      "status": "building",  // "locked", "building", "complete"
      "color": "#6366f1"
    }
  ],
  "materials": [
    { "emoji": "🌊", "percent": 73, "color": "#5b9ea6" }
  ],
  "milestones": [
    { "name": "First Thousand!", "status": "achieved" }  // "locked", "progress", "achieved"
  ],
  "lastUpdate": {
    "date": "January 29, 2025",
    "mood": "🔥",
    "blocks": 347
  }
}
```

## Features

- 📱 **iPad Optimized** - Designed for iPad Mini, works on any device
- 🌙 **Dark Theme** - Easy on the eyes, dramatic presentation
- 🎯 **Spoiler-Free** - Kids see progress without knowing what's being built
- 🔄 **Auto-Refresh** - Updates every 60 seconds
- 🎉 **Fun Interactions** - Pull to refresh, double-tap for confetti
- ⚡ **Fast** - Single HTML file, no build tools needed

## Easter Eggs 🥚

- **Pull down** to refresh (triggers confetti!)
- **Double-tap** anywhere for confetti burst
- Achievements unlock with celebration effects

## Customization

Edit the CSS variables in `index.html` to change colors:

```css
:root {
    --bg-dark: #0a0a12;
    --accent-purple: #6366f1;
    --accent-cyan: #06b6d4;
    --accent-pink: #ec4899;
    /* etc */
}
```

## Troubleshooting

**Dashboard shows "Loading..." forever**
- Check that `data.json` exists and is valid JSON
- Check browser console for errors

**Data not updating**
- GitHub Pages can cache for up to 10 minutes
- Force refresh: add `?v=2` to URL
- Check Make.com scenario is running

**Images not loading**
- Ensure `assets/` folder was pushed
- Check file names match exactly (case-sensitive)

---

Built with ❤️ for Team Streem