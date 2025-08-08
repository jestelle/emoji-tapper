import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// High score document interface
interface HighScore {
  game: string;
  mode: string;
  platform: string;
  player: string;
  score: number;
  datetime: admin.firestore.Timestamp;
  createdAt: admin.firestore.Timestamp;
}

// Time period enum for leaderboard queries
enum TimePeriod {
  DAY = 'day',
  WEEK = 'week',
  MONTH = 'month',
  ALL_TIME = 'all_time'
}

// Validation function for high score data
function validateHighScoreData(data: any): string | null {
  if (!data.game || typeof data.game !== 'string' || data.game.trim().length === 0) {
    return 'Game name is required and must be a non-empty string';
  }
  
  if (!data.mode || typeof data.mode !== 'string' || data.mode.trim().length === 0) {
    return 'Game mode is required and must be a non-empty string';
  }
  
  if (!data.platform || typeof data.platform !== 'string' || data.platform.trim().length === 0) {
    return 'Platform is required and must be a non-empty string';
  }
  
  if (!data.player || typeof data.player !== 'string' || data.player.trim().length === 0) {
    return 'Player name is required and must be a non-empty string';
  }
  
  if (typeof data.score !== 'number' || data.score < 0 || !Number.isInteger(data.score)) {
    return 'Score must be a non-negative integer';
  }
  
  if (data.player.length > 50) {
    return 'Player name must be 50 characters or less';
  }
  
  if (data.game.length > 100) {
    return 'Game name must be 100 characters or less';
  }
  
  if (data.mode.length > 50) {
    return 'Game mode must be 50 characters or less';
  }
  
  if (data.platform.length > 50) {
    return 'Platform must be 50 characters or less';
  }
  
  return null;
}

// Helper function to get date range for time periods
function getDateRange(period: TimePeriod): Date {
  const now = new Date();
  
  switch (period) {
    case TimePeriod.DAY:
      const dayStart = new Date(now);
      dayStart.setHours(0, 0, 0, 0);
      return dayStart;
      
    case TimePeriod.WEEK:
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);
      weekStart.setHours(0, 0, 0, 0);
      return weekStart;
      
    case TimePeriod.MONTH:
      const monthStart = new Date(now);
      monthStart.setMonth(now.getMonth() - 1);
      monthStart.setHours(0, 0, 0, 0);
      return monthStart;
      
    case TimePeriod.ALL_TIME:
      return new Date(0); // Unix epoch
      
    default:
      return new Date(0);
  }
}

/**
 * Submit a new high score
 * POST /submitScore
 * Body: { game, mode, platform, player, score }
 */
export const submitScore = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const data = req.body;
    
    // Validate input data
    const validationError = validateHighScoreData(data);
    if (validationError) {
      res.status(400).json({ error: validationError });
      return;
    }
    
    // Create high score document
    const now = admin.firestore.Timestamp.now();
    const highScore: HighScore = {
      game: data.game.trim(),
      mode: data.mode.trim(),
      platform: data.platform.trim(),
      player: data.player.trim(),
      score: data.score,
      datetime: now,
      createdAt: now
    };
    
    // Save to Firestore
    const docRef = await db.collection('highscores').add(highScore);
    
    res.status(201).json({
      success: true,
      id: docRef.id,
      message: 'High score submitted successfully'
    });
    
  } catch (error) {
    console.error('Error submitting score:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Get top high scores for a specific game, mode, and platform
 * GET /getTopScores?game=EmojiTapper&mode=Classic&platform=iOS&period=day&limit=10
 */
export const getTopScores = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const game = req.query.game as string;
    const mode = req.query.mode as string;
    const platform = req.query.platform as string;
    const period = (req.query.period as string) || TimePeriod.ALL_TIME;
    const limit = parseInt(req.query.limit as string) || 10;
    
    // Validate required parameters
    if (!game || !mode || !platform) {
      res.status(400).json({ error: 'Game, mode, and platform parameters are required' });
      return;
    }
    
    // Validate period
    if (!Object.values(TimePeriod).includes(period as TimePeriod)) {
      res.status(400).json({ 
        error: 'Invalid period. Must be one of: day, week, month, all_time' 
      });
      return;
    }
    
    // Validate limit
    if (limit < 1 || limit > 100) {
      res.status(400).json({ error: 'Limit must be between 1 and 100' });
      return;
    }
    
    // Build query
    let query = db.collection('highscores')
      .where('game', '==', game)
      .where('mode', '==', mode)
      .where('platform', '==', platform);
    
    // Add time filter if not all-time
    if (period !== TimePeriod.ALL_TIME) {
      const startDate = getDateRange(period as TimePeriod);
      query = query.where('datetime', '>=', admin.firestore.Timestamp.fromDate(startDate));
    }
    
    // Order by score descending and limit results
    query = query.orderBy('score', 'desc').limit(limit);
    
    const snapshot = await query.get();
    
    const scores = snapshot.docs.map(doc => {
      const data = doc.data() as HighScore;
      return {
        id: doc.id,
        game: data.game,
        mode: data.mode,
        platform: data.platform,
        player: data.player,
        score: data.score,
        datetime: data.datetime.toDate().toISOString()
      };
    });
    
    res.status(200).json({
      success: true,
      scores,
      count: scores.length,
      period,
      game,
      mode,
      platform
    });
    
  } catch (error) {
    console.error('Error getting top scores:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Get player's personal best for a specific game, mode, and platform
 * GET /getPlayerBest?game=EmojiTapper&mode=Classic&platform=iOS&player=Josh
 */
export const getPlayerBest = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const game = req.query.game as string;
    const mode = req.query.mode as string;
    const platform = req.query.platform as string;
    const player = req.query.player as string;
    
    // Validate required parameters
    if (!game || !mode || !platform || !player) {
      res.status(400).json({ error: 'Game, mode, platform, and player parameters are required' });
      return;
    }
    
    // Query for player's best score
    const snapshot = await db.collection('highscores')
      .where('game', '==', game)
      .where('mode', '==', mode)
      .where('platform', '==', platform)
      .where('player', '==', player)
      .orderBy('score', 'desc')
      .limit(1)
      .get();
    
    if (snapshot.empty) {
      res.status(200).json({
        success: true,
        playerBest: null,
        message: 'No scores found for this player'
      });
      return;
    }
    
    const doc = snapshot.docs[0];
    const data = doc.data() as HighScore;
    
    const playerBest = {
      id: doc.id,
      game: data.game,
      mode: data.mode,
      platform: data.platform,
      player: data.player,
      score: data.score,
      datetime: data.datetime.toDate().toISOString()
    };
    
    res.status(200).json({
      success: true,
      playerBest
    });
    
  } catch (error) {
    console.error('Error getting player best:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Get leaderboard stats (total players, total scores, etc.)
 * GET /getLeaderboardStats?game=EmojiTapper&mode=Classic&platform=iOS
 */
export const getLeaderboardStats = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const game = req.query.game as string;
    const mode = req.query.mode as string;
    const platform = req.query.platform as string;
    
    // Validate required parameters
    if (!game || !mode || !platform) {
      res.status(400).json({ error: 'Game, mode, and platform parameters are required' });
      return;
    }
    
    // Get all scores for this game/mode/platform
    const snapshot = await db.collection('highscores')
      .where('game', '==', game)
      .where('mode', '==', mode)
      .where('platform', '==', platform)
      .get();
    
    const scores = snapshot.docs.map(doc => doc.data() as HighScore);
    const uniquePlayers = new Set(scores.map(score => score.player)).size;
    const highestScore = scores.length > 0 ? Math.max(...scores.map(score => score.score)) : 0;
    const averageScore = scores.length > 0 ? Math.round(scores.reduce((sum, score) => sum + score.score, 0) / scores.length) : 0;
    
    res.status(200).json({
      success: true,
      stats: {
        totalScores: scores.length,
        uniquePlayers,
        highestScore,
        averageScore,
        game,
        mode,
        platform
      }
    });
    
  } catch (error) {
    console.error('Error getting leaderboard stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});