// Test script for the Emoji Tapper Leaderboard API
// Run with: node test-api.js

const BASE_URL = 'http://localhost:5001/top-leaderboard/us-central1';

async function testAPI() {
  console.log('🧪 Testing Emoji Tapper Leaderboard API\n');

  // Test 1: Submit a high score
  console.log('1️⃣ Testing score submission...');
  try {
    const submitResponse = await fetch(`${BASE_URL}/submitScore`, {
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
    
    const submitResult = await submitResponse.json();
    console.log('✅ Score submitted:', submitResult);
  } catch (error) {
    console.log('❌ Error submitting score:', error.message);
  }

  // Submit a few more test scores
  const testScores = [
    { player: 'Alice', score: 98 },
    { player: 'Bob', score: 87 },
    { player: 'Carol', score: 123 },
    { player: 'David', score: 76 }
  ];

  for (const testScore of testScores) {
    try {
      await fetch(`${BASE_URL}/submitScore`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          game: 'Emoji Tapper',
          mode: 'Classic',
          platform: 'iOS',
          ...testScore
        })
      });
      console.log(`✅ Test score submitted: ${testScore.player} - ${testScore.score}`);
    } catch (error) {
      console.log(`❌ Error submitting test score for ${testScore.player}:`, error.message);
    }
  }

  // Wait a moment for data to be processed
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Test 2: Get top scores
  console.log('\n2️⃣ Testing top scores retrieval...');
  try {
    const params = new URLSearchParams({
      game: 'Emoji Tapper',
      mode: 'Classic',
      platform: 'iOS',
      period: 'all_time',
      limit: '10'
    });
    
    const topScoresResponse = await fetch(`${BASE_URL}/getTopScores?${params}`);
    const topScoresResult = await topScoresResponse.json();
    console.log('✅ Top scores retrieved:');
    console.log(`   Found ${topScoresResult.count} scores`);
    topScoresResult.scores.forEach((score, index) => {
      console.log(`   ${index + 1}. ${score.player}: ${score.score}`);
    });
  } catch (error) {
    console.log('❌ Error getting top scores:', error.message);
  }

  // Test 3: Get player best
  console.log('\n3️⃣ Testing player best score...');
  try {
    const params = new URLSearchParams({
      game: 'Emoji Tapper',
      mode: 'Classic',
      platform: 'iOS',
      player: 'Josh'
    });
    
    const playerBestResponse = await fetch(`${BASE_URL}/getPlayerBest?${params}`);
    const playerBestResult = await playerBestResponse.json();
    console.log('✅ Player best retrieved:');
    if (playerBestResult.playerBest) {
      console.log(`   ${playerBestResult.playerBest.player}: ${playerBestResult.playerBest.score}`);
    } else {
      console.log('   No scores found for player');
    }
  } catch (error) {
    console.log('❌ Error getting player best:', error.message);
  }

  // Test 4: Get leaderboard stats
  console.log('\n4️⃣ Testing leaderboard stats...');
  try {
    const params = new URLSearchParams({
      game: 'Emoji Tapper',
      mode: 'Classic',
      platform: 'iOS'
    });
    
    const statsResponse = await fetch(`${BASE_URL}/getLeaderboardStats?${params}`);
    const statsResult = await statsResponse.json();
    console.log('✅ Leaderboard stats retrieved:');
    console.log(`   Total Scores: ${statsResult.stats.totalScores}`);
    console.log(`   Unique Players: ${statsResult.stats.uniquePlayers}`);
    console.log(`   Highest Score: ${statsResult.stats.highestScore}`);
    console.log(`   Average Score: ${statsResult.stats.averageScore}`);
  } catch (error) {
    console.log('❌ Error getting leaderboard stats:', error.message);
  }

  // Test 5: Test validation errors
  console.log('\n5️⃣ Testing validation errors...');
  try {
    const invalidResponse = await fetch(`${BASE_URL}/submitScore`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        game: '',
        mode: 'Classic',
        platform: 'iOS',
        player: 'Test',
        score: -5
      })
    });
    
    const invalidResult = await invalidResponse.json();
    if (invalidResponse.status === 400) {
      console.log('✅ Validation error caught correctly:', invalidResult.error);
    } else {
      console.log('❌ Expected validation error, got:', invalidResult);
    }
  } catch (error) {
    console.log('❌ Error testing validation:', error.message);
  }

  // Test 6: Test Penguin Ball mode
  console.log('\n6️⃣ Testing Penguin Ball mode...');
  try {
    const penguinResponse = await fetch(`${BASE_URL}/submitScore`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        game: 'Emoji Tapper',
        mode: 'Penguin Ball',
        platform: 'iOS',
        player: 'Josh',
        score: 89
      })
    });
    
    const penguinResult = await penguinResponse.json();
    console.log('✅ Penguin Ball score submitted:', penguinResult);

    // Get Penguin Ball leaderboard
    const penguinParams = new URLSearchParams({
      game: 'Emoji Tapper',
      mode: 'Penguin Ball',
      platform: 'iOS',
      period: 'all_time',
      limit: '10'
    });
    
    const penguinTopResponse = await fetch(`${BASE_URL}/getTopScores?${penguinParams}`);
    const penguinTopResult = await penguinTopResponse.json();
    console.log('✅ Penguin Ball leaderboard:', penguinTopResult);
  } catch (error) {
    console.log('❌ Error testing Penguin Ball mode:', error.message);
  }

  console.log('\n🎉 API testing complete!');
  console.log('\n💡 Next steps:');
  console.log('   1. Update BASE_URL with your actual Firebase project ID');
  console.log('   2. Deploy functions: firebase deploy --only functions');
  console.log('   3. Test with production URLs');
  console.log('   4. Integrate into your Swift app');
}

// Check if fetch is available (Node.js 18+)
if (typeof fetch === 'undefined') {
  console.log('❌ This script requires Node.js 18+ with built-in fetch support');
  console.log('   Or install node-fetch: npm install node-fetch');
  process.exit(1);
}

// Run the tests
testAPI().catch(console.error);