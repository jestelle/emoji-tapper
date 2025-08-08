# Emoji Tapper Leaderboard Service

A Firebase Cloud Functions-based leaderboard service for the Emoji Tapper game, providing high score submission and retrieval functionality.

## Setup

### Prerequisites
- Node.js 18 or higher
- Firebase CLI (`npm install -g firebase-tools`)
- Firebase project (✅ `top-leaderboard`)
- Java 8+ (for local emulators only)

### Installation

1. **Clone/navigate to the firebase-leaderboard directory**
   ```bash
   cd firebase-leaderboard
   ```

2. **Install dependencies**
   ```bash
   npm install
   cd functions
   npm install
   cd ..
   ```

3. **Build TypeScript functions** (✅ Already configured)
   ```bash
   cd top-leaderboard
   npm run build
   cd ..
   ```

5. **Deploy to Firebase**
   ```bash
   firebase deploy
   ```

### Local Development

To run the functions locally with emulators:

```bash
firebase emulators:start
```

This will start:
- Functions emulator on port 5001
- Firestore emulator on port 8080
- Firebase UI on http://localhost:4000

## Database Schema

### HighScore Document
```typescript
interface HighScore {
  game: string;        // "Emoji Tapper"
  mode: string;        // "Classic" or "Penguin Ball"
  platform: string;    // "iOS", "macOS", "watchOS"
  player: string;      // Player name (max 50 chars)
  score: number;       // Non-negative integer
  datetime: Timestamp; // When the score was achieved
  createdAt: Timestamp; // When the record was created
}
```

### Collection Structure
```
/highscores/{documentId}
  - game: "Emoji Tapper"
  - mode: "Classic"
  - platform: "iOS"
  - player: "Josh"
  - score: 115
  - datetime: 2025-08-08T15:45:00Z
  - createdAt: 2025-08-08T15:45:00Z
```

## API Endpoints

Base URL: `https://us-central1-top-leaderboard.cloudfunctions.net/`

### 1. Submit High Score

**Endpoint:** `POST /submitScore`

**Description:** Submit a new high score to the leaderboard.

**Request Body:**
```json
{
  "game": "Emoji Tapper",
  "mode": "Classic",
  "platform": "iOS",
  "player": "Josh",
  "score": 115
}
```

**Response:**
```json
{
  "success": true,
  "id": "document_id",
  "message": "High score submitted successfully"
}
```

**Error Response:**
```json
{
  "error": "Validation error message"
}
```

**Status Codes:**
- `201`: Score submitted successfully
- `400`: Invalid request data
- `500`: Internal server error

### 2. Get Top Scores

**Endpoint:** `GET /getTopScores`

**Description:** Retrieve top high scores for a specific game and mode.

**Query Parameters:**
- `game` (required): Game name (e.g., "Emoji Tapper")
- `mode` (required): Game mode (e.g., "Classic", "Penguin Ball")
- `platform` (required): Platform (e.g., "iOS", "macOS", "watchOS")
- `period` (optional): Time period - "day", "week", "month", "all_time" (default: "all_time")
- `limit` (optional): Number of scores to return (1-100, default: 10)

**Example:**
```
GET /getTopScores?game=Emoji%20Tapper&mode=Classic&platform=iOS&period=week&limit=5
```

**Response:**
```json
{
  "success": true,
  "scores": [
    {
      "id": "doc_id_1",
      "game": "Emoji Tapper",
      "mode": "Classic",
      "platform": "iOS",
      "player": "Josh",
      "score": 115,
      "datetime": "2025-08-08T15:45:00.000Z"
    },
    {
      "id": "doc_id_2",
      "game": "Emoji Tapper",
      "mode": "Classic",
      "platform": "iOS",
      "player": "Alice",
      "score": 98,
      "datetime": "2025-08-08T14:30:00.000Z"
    }
  ],
  "count": 2,
  "period": "week",
  "game": "Emoji Tapper",
  "mode": "Classic",
  "platform": "iOS"
}
```

### 3. Get Player Best

**Endpoint:** `GET /getPlayerBest`

**Description:** Get a specific player's personal best score for a game mode.

**Query Parameters:**
- `game` (required): Game name
- `mode` (required): Game mode
- `platform` (required): Platform
- `player` (required): Player name

**Example:**
```
GET /getPlayerBest?game=Emoji%20Tapper&mode=Classic&platform=iOS&player=Josh
```

**Response:**
```json
{
  "success": true,
  "playerBest": {
    "id": "doc_id",
    "game": "Emoji Tapper",
    "mode": "Classic",
    "platform": "iOS",
    "player": "Josh",
    "score": 115,
    "datetime": "2025-08-08T15:45:00.000Z"
  }
}
```

**Response (No scores found):**
```json
{
  "success": true,
  "playerBest": null,
  "message": "No scores found for this player"
}
```

### 4. Get Leaderboard Stats

**Endpoint:** `GET /getLeaderboardStats`

**Description:** Get statistics about the leaderboard for a specific game and mode.

**Query Parameters:**
- `game` (required): Game name
- `mode` (required): Game mode

**Example:**
```
GET /getLeaderboardStats?game=Emoji%20Tapper&mode=Classic&platform=iOS
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalScores": 25,
    "uniquePlayers": 8,
    "highestScore": 115,
    "averageScore": 67,
    "game": "Emoji Tapper",
    "mode": "Classic",
    "platform": "iOS"
  }
}
```

## Validation Rules

### Score Submission
- `game`: Required, non-empty string, max 100 characters
- `mode`: Required, non-empty string, max 50 characters
- `platform`: Required, non-empty string, max 50 characters
- `player`: Required, non-empty string, max 50 characters
- `score`: Required, non-negative integer

### Query Parameters
- Time periods: "day", "week", "month", "all_time"
- Limit: 1-100 (default: 10)

## Security

- All write operations go through Cloud Functions for validation
- Direct Firestore writes are blocked by security rules
- Read access to high scores is public
- CORS is enabled for web clients
- Input validation prevents malicious data

## Time Periods

- **day**: Scores from today (00:00:00 to now)
- **week**: Scores from the last 7 days
- **month**: Scores from the last 30 days
- **all_time**: All scores ever recorded

## Error Handling

All endpoints return consistent error responses:

```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created (for score submission)
- `400`: Bad Request (validation errors)
- `405`: Method Not Allowed
- `500`: Internal Server Error

## Examples

### Submit a Score (JavaScript)
```javascript
const response = await fetch('https://us-central1-top-leaderboard.cloudfunctions.net/submitScore', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    game: 'Emoji Tapper',
    mode: 'Classic',
    platform: 'iOS',
    player: 'Josh',
    score: 115
  })
});

const result = await response.json();
console.log(result);
```

### Get Top Scores (JavaScript)
```javascript
const params = new URLSearchParams({
  game: 'Emoji Tapper',
  mode: 'Classic',
  platform: 'iOS',
  period: 'week',
  limit: '10'
});

const response = await fetch(`https://us-central1-top-leaderboard.cloudfunctions.net/getTopScores?${params}`);
const result = await response.json();
console.log(result.scores);
```

## Development & Testing

### Run Local Emulators
```bash
firebase emulators:start
```

### Test Endpoints Locally
```bash
# Submit score
curl -X POST http://localhost:5001/your-project/us-central1/submitScore \
  -H "Content-Type: application/json" \
  -d '{"game":"Emoji Tapper","mode":"Classic","player":"Josh","score":115}'

# Get top scores
curl "http://localhost:5001/your-project/us-central1/getTopScores?game=Emoji%20Tapper&mode=Classic&period=all_time&limit=10"
```

### Deploy Functions
```bash
firebase deploy --only functions
```

### View Logs
```bash
firebase functions:log
```