// ============================================
// MEGA BUILD TRACKER - Configuration
// ============================================

// API Key is loaded from URL parameter or localStorage
// Usage: Add ?key=YOUR_KEY to URL, or it will prompt once and save
function getApiKey() {
  const urlParams = new URLSearchParams(window.location.search);
  const keyFromUrl = urlParams.get('key');

  if (keyFromUrl) {
    localStorage.setItem('airtable_key', keyFromUrl);
    // Clean URL without reloading
    window.history.replaceState({}, document.title, window.location.pathname);
    return keyFromUrl;
  }

  return localStorage.getItem('airtable_key');
}

const CONFIG = {
  // Airtable Configuration - key loaded dynamically
  get AIRTABLE_API_KEY() {
    return getApiKey();
  },
  AIRTABLE_BASE_ID: 'appmul5QQ7fC0RlfB',

  // Table Names
  TABLES: {
    PROJECTS: 'Projects',
    ZONES: 'Zones',
    STRUCTURES: 'Structures',
    BUILD_SESSIONS: 'Build_Sessions',
    MATERIALS: 'Materials'
  },

  // Refresh interval (in milliseconds) - 5 minutes
  REFRESH_INTERVAL: 5 * 60 * 1000,

  // Fun facts to cycle through
  FUN_FACTS: [
    "Every block placed brings you closer to something epic!",
    "Master builders always plan before they build!",
    "The biggest builds start with a single block!",
    "Teamwork makes the dream work!",
    "Even the Ender Dragon started as an egg!",
    "Great builders never give up!",
    "Your world, your rules, your adventure!",
    "Legends are built one block at a time!",
    "The best treasures are the ones we build together!",
    "Keep calm and mine on!",
    "Every expert was once a beginner!",
    "Building is believing!"
  ],

  // Mood emojis mapping
  MOOD_EMOJIS: {
    '🏆 Master Builder': '🏆',
    '😤 Creeper Problems': '😤',
    '🧱 Brick by Brick': '🧱',
    '🔥 On Fire': '🔥',
    '😴 Mined Out': '😴'
  },

  // Structure type icons
  STRUCTURE_ICONS: {
    'Platform': '🏗️',
    'Tower': '🗼',
    'Chamber': '🏛️',
    'System': '⚙️',
    'Other': '🧱'
  }
};
