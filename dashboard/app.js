// ============================================
// MEGA BUILD TRACKER - Main Application
// Team Streem Kids Dashboard
// ============================================

class MegaBuildTracker {
  constructor() {
    this.zones = [];
    this.structures = [];
    this.sessions = [];
    this.currentTab = 'zones';
    this.lastProgress = 0;

    this.init();
  }

  async init() {
    this.setupTabNavigation();
    this.startFunFactRotation();

    // Check for API key
    if (!CONFIG.AIRTABLE_API_KEY) {
      this.showSetupPrompt();
      return;
    }

    await this.loadAllData();
    this.setupAutoRefresh();
  }

  showSetupPrompt() {
    const content = document.querySelector('.content');
    content.innerHTML = `
      <div class="setup-prompt">
        <div class="setup-icon">🔑</div>
        <h2>Welcome to Team Streem!</h2>
        <p>Ask a parent to set up the dashboard with the special link.</p>
        <div class="setup-hint">
          <small>Parents: Add <code>?key=YOUR_API_KEY</code> to the URL</small>
        </div>
      </div>
    `;

    // Add styles for setup prompt
    const style = document.createElement('style');
    style.textContent = `
      .setup-prompt {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
        text-align: center;
        padding: 2rem;
      }
      .setup-icon { font-size: 4rem; margin-bottom: 1rem; }
      .setup-prompt h2 {
        background: linear-gradient(135deg, var(--emerald), var(--diamond));
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0.5rem;
      }
      .setup-prompt p { color: var(--text-secondary); margin-bottom: 1.5rem; }
      .setup-hint {
        background: var(--bg-card);
        padding: 1rem;
        border-radius: var(--radius-md);
        color: var(--text-muted);
      }
      .setup-hint code {
        background: var(--bg-dark);
        padding: 0.2rem 0.5rem;
        border-radius: 4px;
        font-family: monospace;
      }
    `;
    document.head.appendChild(style);
  }

  // ============================================
  // Airtable API Methods
  // ============================================

  async fetchFromAirtable(tableName, options = {}) {
    const baseUrl = `https://api.airtable.com/v0/${CONFIG.AIRTABLE_BASE_ID}/${encodeURIComponent(tableName)}`;

    const params = new URLSearchParams();
    if (options.maxRecords) params.append('maxRecords', options.maxRecords);
    if (options.sort) {
      options.sort.forEach((s, i) => {
        params.append(`sort[${i}][field]`, s.field);
        params.append(`sort[${i}][direction]`, s.direction);
      });
    }
    if (options.filterByFormula) {
      params.append('filterByFormula', options.filterByFormula);
    }

    const url = params.toString() ? `${baseUrl}?${params}` : baseUrl;

    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${CONFIG.AIRTABLE_API_KEY}`
        }
      });

      if (!response.ok) {
        throw new Error(`Airtable error: ${response.status}`);
      }

      const data = await response.json();
      return data.records;
    } catch (error) {
      console.error(`Error fetching ${tableName}:`, error);
      return [];
    }
  }

  // ============================================
  // Data Loading
  // ============================================

  async loadAllData() {
    // Load all data in parallel
    const [zones, structures, sessions] = await Promise.all([
      this.fetchFromAirtable(CONFIG.TABLES.ZONES),
      this.fetchFromAirtable(CONFIG.TABLES.STRUCTURES, {
        filterByFormula: '{Is_Visible_To_Kids}=1'
      }),
      this.fetchFromAirtable(CONFIG.TABLES.BUILD_SESSIONS, {
        filterByFormula: '{Is_Visible_To_Kids}=1',
        sort: [{ field: 'Session_Date', direction: 'desc' }],
        maxRecords: 20
      })
    ]);

    this.zones = zones;
    this.structures = structures;
    this.sessions = sessions;

    this.updateMainProgress();
    this.renderZones();
    this.renderStructures();
    this.renderSessions();
    this.updateStreak();
  }

  // ============================================
  // Progress Calculations
  // ============================================

  updateMainProgress() {
    let totalPlanned = 0;
    let totalPlaced = 0;

    // Sum up blocks from structures
    this.structures.forEach(structure => {
      const fields = structure.fields;
      totalPlanned += fields.Blocks_Planned || 0;
      totalPlaced += fields.Blocks_Placed_Rollup || 0;
    });

    // Also check zones for rollup data
    this.zones.forEach(zone => {
      const fields = zone.fields;
      if (fields.Blocks_Planned_Rollup) {
        totalPlanned += fields.Blocks_Planned_Rollup;
      }
      if (fields.Blocks_Placed_Rollup) {
        totalPlaced += fields.Blocks_Placed_Rollup;
      }
    });

    const progress = totalPlanned > 0 ? Math.round((totalPlaced / totalPlanned) * 100) : 0;

    // Animate the progress ring
    this.animateProgressRing(progress);

    // Update text displays
    document.getElementById('totalProgress').textContent = `${progress}%`;
    document.getElementById('blocksPlaced').textContent = this.formatNumber(totalPlaced);
    document.getElementById('blocksTotal').textContent = this.formatNumber(totalPlanned);

    // Check for celebration milestones
    this.checkMilestones(progress);

    this.lastProgress = progress;
  }

  animateProgressRing(progress) {
    const ring = document.getElementById('progressRing');
    const circumference = 2 * Math.PI * 85; // r=85
    const offset = circumference - (progress / 100) * circumference;
    ring.style.strokeDashoffset = offset;
  }

  checkMilestones(progress) {
    const milestones = [25, 50, 75, 100];

    for (const milestone of milestones) {
      if (progress >= milestone && this.lastProgress < milestone) {
        this.showCelebration(milestone);
        break;
      }
    }
  }

  showCelebration(milestone) {
    const messages = {
      25: "Quarter of the way there! Keep building!",
      50: "HALFWAY! You're doing amazing!",
      75: "Almost there! The finish line is in sight!",
      100: "YOU DID IT! The mega build is COMPLETE!"
    };

    const overlay = document.getElementById('celebrationOverlay');
    const message = document.getElementById('celebrationMessage');
    message.textContent = messages[milestone];
    overlay.classList.add('active');

    setTimeout(() => {
      overlay.classList.remove('active');
    }, 3000);
  }

  // ============================================
  // Rendering Methods
  // ============================================

  renderZones() {
    const grid = document.getElementById('zonesGrid');

    if (this.zones.length === 0) {
      grid.innerHTML = `
        <div class="empty-state" style="grid-column: span 2;">
          <div class="empty-icon">🏔️</div>
          <div class="empty-title">No Zones Yet</div>
          <div class="empty-message">Zones will appear here as the build progresses!</div>
        </div>
      `;
      return;
    }

    grid.innerHTML = this.zones
      .filter(zone => zone.fields.Zone_Display) // Only show zones with display names
      .sort((a, b) => (a.fields.Zone_Number || 0) - (b.fields.Zone_Number || 0))
      .map(zone => this.createZoneCard(zone))
      .join('');
  }

  createZoneCard(zone) {
    const fields = zone.fields;
    const name = fields.Zone_Display || 'Mystery Zone';
    const number = fields.Zone_Number || '?';
    const progress = Math.round((fields.Progress || 0) * 100);
    const blocksPlaced = fields.Blocks_Placed_Rollup || 0;
    const blocksPlanned = fields.Blocks_Planned_Rollup || 0;
    const layers = fields.Layers_Complete || 0;
    const totalLayers = fields.Total_Layers || 0;

    return `
      <div class="zone-card" style="--progress: ${progress / 100}">
        <div class="zone-header">
          <span class="zone-number">Zone ${number}</span>
          <span class="zone-progress-badge">${progress}%</span>
        </div>
        <div class="zone-name">${this.escapeHtml(name)}</div>
        <div class="zone-stats">
          <div class="zone-stat">
            <span>Blocks</span>
            <span>${this.formatNumber(blocksPlaced)}/${this.formatNumber(blocksPlanned)}</span>
          </div>
          ${totalLayers > 0 ? `
            <div class="zone-stat">
              <span>Layers</span>
              <span>${layers}/${totalLayers}</span>
            </div>
          ` : ''}
        </div>
        <div class="zone-progress-bar">
          <div class="zone-progress-fill" style="width: ${progress}%"></div>
        </div>
      </div>
    `;
  }

  renderStructures() {
    const list = document.getElementById('structuresList');

    if (this.structures.length === 0) {
      list.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🏗️</div>
          <div class="empty-title">No Builds Unlocked</div>
          <div class="empty-message">Keep playing to unlock build previews!</div>
        </div>
      `;
      return;
    }

    list.innerHTML = this.structures
      .filter(s => s.fields.Structure_Display)
      .map(structure => this.createStructureCard(structure))
      .join('');
  }

  createStructureCard(structure) {
    const fields = structure.fields;
    const name = fields.Structure_Display || 'Secret Build';
    const type = fields.Structure_Type || 'Other';
    const icon = CONFIG.STRUCTURE_ICONS[type] || '🧱';
    const description = fields.What_We_Tell_The_Kids || '';
    const progress = Math.round((fields.Progress || 0) * 100);
    const blocksPlaced = fields.Blocks_Placed_Rollup || 0;
    const blocksPlanned = fields.Blocks_Planned || 0;

    return `
      <div class="structure-card">
        <div class="structure-icon">${icon}</div>
        <div class="structure-content">
          <div class="structure-header">
            <span class="structure-name">${this.escapeHtml(name)}</span>
            <span class="structure-type">${type}</span>
          </div>
          ${description ? `<div class="structure-description">${this.escapeHtml(description)}</div>` : ''}
          <div class="structure-progress">
            <div class="structure-progress-bar">
              <div class="structure-progress-fill" style="width: ${progress}%"></div>
            </div>
            <span class="structure-progress-text">${progress}%</span>
          </div>
        </div>
      </div>
    `;
  }

  renderSessions() {
    const timeline = document.getElementById('sessionsTimeline');

    if (this.sessions.length === 0) {
      timeline.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">📅</div>
          <div class="empty-title">No Sessions Yet</div>
          <div class="empty-message">Build sessions will show up here!</div>
        </div>
      `;
      return;
    }

    timeline.innerHTML = this.sessions
      .filter(s => s.fields.Session_Date)
      .map(session => this.createSessionCard(session))
      .join('');
  }

  createSessionCard(session) {
    const fields = session.fields;
    const date = this.formatDate(fields.Session_Date);
    const mood = fields.Mood || '';
    const moodEmoji = CONFIG.MOOD_EMOJIS[mood] || '🎮';
    const blocksPlaced = fields.Blocks_Placed_This_Session || 0;
    const duration = fields.Duration_Minutes || 0;
    const notes = fields.Notes_Display || '';
    const photo = fields.Photo?.[0]?.thumbnails?.large?.url;

    return `
      <div class="session-card">
        <div class="session-header">
          <span class="session-date">${date}</span>
          <span class="session-mood" title="${mood}">${moodEmoji}</span>
        </div>
        <div class="session-stats">
          <div class="session-stat">
            <span class="session-stat-value">${this.formatNumber(blocksPlaced)}</span>
            <span class="session-stat-label">blocks</span>
          </div>
          <div class="session-stat">
            <span class="session-stat-value">${duration}</span>
            <span class="session-stat-label">minutes</span>
          </div>
        </div>
        ${notes ? `<div class="session-notes">"${this.escapeHtml(notes)}"</div>` : ''}
        ${photo ? `
          <div class="session-photo">
            <img src="${photo}" alt="Build session photo" loading="lazy">
          </div>
        ` : ''}
      </div>
    `;
  }

  // ============================================
  // Streak Tracking
  // ============================================

  updateStreak() {
    // Calculate streak based on consecutive days with sessions
    const sessionDates = this.sessions
      .map(s => s.fields.Session_Date)
      .filter(Boolean)
      .map(d => new Date(d).toDateString())
      .filter((d, i, arr) => arr.indexOf(d) === i) // unique dates
      .sort((a, b) => new Date(b) - new Date(a)); // most recent first

    let streak = 0;
    const today = new Date().toDateString();
    const yesterday = new Date(Date.now() - 86400000).toDateString();

    if (sessionDates[0] === today || sessionDates[0] === yesterday) {
      streak = 1;
      for (let i = 1; i < sessionDates.length; i++) {
        const current = new Date(sessionDates[i - 1]);
        const prev = new Date(sessionDates[i]);
        const diffDays = Math.round((current - prev) / 86400000);

        if (diffDays === 1) {
          streak++;
        } else {
          break;
        }
      }
    }

    document.getElementById('streakCount').textContent = streak;

    // Hide streak badge if no streak
    const badge = document.getElementById('streakBadge');
    badge.style.display = streak > 0 ? 'flex' : 'none';
  }

  // ============================================
  // Tab Navigation
  // ============================================

  setupTabNavigation() {
    const tabs = document.querySelectorAll('.tab-btn');
    const panels = document.querySelectorAll('.panel');

    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const targetTab = tab.dataset.tab;

        // Update active states
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');

        panels.forEach(panel => {
          panel.classList.remove('active');
          if (panel.id === `${targetTab}Panel`) {
            panel.classList.add('active');
          }
        });

        this.currentTab = targetTab;
      });
    });
  }

  // ============================================
  // Fun Facts
  // ============================================

  startFunFactRotation() {
    this.updateFunFact();
    setInterval(() => this.updateFunFact(), 10000); // Every 10 seconds
  }

  updateFunFact() {
    const factText = document.querySelector('.fact-text');
    const facts = CONFIG.FUN_FACTS;
    const randomFact = facts[Math.floor(Math.random() * facts.length)];

    factText.style.opacity = 0;
    setTimeout(() => {
      factText.textContent = randomFact;
      factText.style.opacity = 1;
    }, 300);
  }

  // ============================================
  // Auto Refresh
  // ============================================

  setupAutoRefresh() {
    setInterval(() => {
      this.loadAllData();
    }, CONFIG.REFRESH_INTERVAL);
  }

  // ============================================
  // Utility Methods
  // ============================================

  formatNumber(num) {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + 'M';
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'K';
    }
    return Math.round(num).toLocaleString();
  }

  formatDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const options = { weekday: 'short', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}

// Initialize the app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.megaBuildTracker = new MegaBuildTracker();
});

// Tap to dismiss celebration
document.getElementById('celebrationOverlay').addEventListener('click', function() {
  this.classList.remove('active');
});
