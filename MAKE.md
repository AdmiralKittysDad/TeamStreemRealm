# Make.com → GitHub Pages Automation

This scenario pulls data from Airtable and updates your GitHub Pages `data.json` file.

## Prerequisites

1. GitHub Personal Access Token
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` scope
   - Save the token securely

2. Your GitHub repo info:
   - Owner: your GitHub username
   - Repo: your repository name
   - Branch: `main`
   - File path: `data.json`

## Make.com Scenario

### Module 1: Trigger
**Type:** Schedule  
**Interval:** Every 15 minutes (or after each Airtable update via webhook)

### Module 2: Get Airtable Data - Materials
**Type:** Airtable - Search Records  
**Table:** Materials  
**Formula:** (none - get all)

### Module 3: Aggregate Materials
**Type:** Array Aggregator  
**Source:** Module 2  
**Structure:**
```
[
  { "emoji": Display_Emoji, "percent": Progress_Pct, "color": Display_Color }
]
```

Also calculate:
- Total Blocks Placed: SUM of Blocks_Placed
- Total Blocks Planned: SUM of Blocks_Planned

### Module 4: Get Airtable Data - Zones
**Type:** Airtable - Search Records  
**Table:** Zones  
**Filter:** Is_Visible_To_Kids = TRUE  
**Sort:** Sort_Order ASC

### Module 5: Aggregate Zones
**Type:** Array Aggregator  
Map to:
```
[
  {
    "name": Zone_Display,
    "codename": Display_Codename,
    "emoji": Display_Emoji,
    "percent": Block_Progress_Pct,
    "status": (convert Status to "locked"/"building"/"complete"),
    "color": Display_Color
  }
]
```

### Module 6: Get Airtable Data - Milestones
**Type:** Airtable - Search Records  
**Table:** Milestones  
**Filter:** Is_Visible_To_Kids = TRUE  
**Sort:** Sort_Order ASC

### Module 7: Aggregate Milestones
**Type:** Array Aggregator  
Map to:
```
[
  {
    "name": Milestone_Display,
    "status": (convert to "locked"/"progress"/"achieved")
  }
]
```

### Module 8: Get Countdown
**Type:** Airtable - Search Records  
**Table:** Countdowns  
**Filter:** Countdown_Display contains "REVEAL"  
**Limit:** 1

### Module 9: Get Latest Session
**Type:** Airtable - Search Records  
**Table:** Build_Sessions  
**Sort:** Session_Date DESC  
**Limit:** 1

### Module 10: Build JSON
**Type:** Tools - Set Variable  

Build the complete JSON object:
```json
{
  "stats": {
    "blocksPlaced": {{materials_total_placed}},
    "blocksTotal": {{materials_total_planned}},
    "overallPercent": {{round(materials_total_placed / materials_total_planned * 100)}},
    "daysToReveal": {{countdown.Days_Remaining}}
  },
  "zones": {{zones_array}},
  "materials": {{materials_array}},
  "milestones": {{milestones_array}},
  "lastUpdate": {
    "date": "{{formatDate(latest_session.Session_Date, 'MMMM D, YYYY')}}",
    "mood": "{{latest_session.Mood}}",
    "blocks": {{latest_session.Blocks_Placed_Session}}
  }
}
```

### Module 11: Get Current File SHA
**Type:** HTTP - Make a request

This is required to update an existing file on GitHub.

```
URL: https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/contents/data.json
Method: GET
Headers:
  Authorization: Bearer YOUR_GITHUB_TOKEN
  Accept: application/vnd.github.v3+json
```

Parse response to get `sha` field.

### Module 12: Update GitHub File
**Type:** HTTP - Make a request

```
URL: https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/contents/data.json
Method: PUT
Headers:
  Authorization: Bearer YOUR_GITHUB_TOKEN
  Accept: application/vnd.github.v3+json
  Content-Type: application/json
Body:
{
  "message": "Update dashboard data",
  "content": "{{base64(json_content)}}",
  "sha": "{{sha_from_module_11}}",
  "branch": "main"
}
```

## Status Conversion Logic

**Zone Status:**
- If Airtable Status = "✅ Complete" → "complete"
- If Airtable Status = "🏗️ Active" → "building"  
- If Airtable Status = "🔧 Finishing" → "building"
- Else → "locked"

**Milestone Status:**
- If Airtable Status = "✅ Achieved" → "achieved"
- If Airtable Status = "🎯 In Progress" → "progress"
- Else → "locked"

## Simplified Alternative: JSON Aggregator

If the module-by-module approach is complex, use Make's JSON module:

1. Get all Airtable data in parallel
2. Use a single **Tools - Set Multiple Variables** to build the object
3. Use **JSON - Create JSON** to stringify
4. Send to GitHub

## Testing

1. Run scenario manually
2. Check GitHub repo - `data.json` should be updated
3. Check GitHub Pages site - should show new data within 1-2 minutes
4. Verify no _Prod fields leaked into the JSON!

## Error Handling

Add error handlers for:
- Airtable connection failures
- GitHub API rate limits (5000/hour for authenticated)
- Invalid JSON structure

## Trigger Options

**Option A: Scheduled**
- Run every 15-60 minutes
- Simple, reliable

**Option B: Webhook from Airtable**
- Trigger when Build_Sessions or Materials updated
- More real-time, uses more operations

**Option C: Manual + Scheduled**
- Manual trigger for immediate updates
- Scheduled nightly backup

## Security Notes

- GitHub token should have minimal permissions (just repo access)
- Airtable token should be read-only if possible
- Never expose tokens in the dashboard code
- The data.json file is public - double-check no sensitive data!