#!/bin/bash

# Debug script for Firebase Functions API
# Run this to test different API endpoints and see what's in the database

BASE_URL="https://us-central1-top-leaderboard.cloudfunctions.net"

echo "🔍 Debugging Firebase Functions API"
echo "=================================="

# Test 1: Submit a test score
echo ""
echo "1️⃣ Testing score submission..."
curl -X POST "$BASE_URL/submitScore" \
  -H "Content-Type: application/json" \
  -d '{
    "game": "Emoji Tapper",
    "mode": "Classic",
    "platform": "iOS",
    "player": "DebugTest",
    "score": 999
  }'

echo ""
echo ""

# Test 2: Get top scores for Classic mode
echo "2️⃣ Testing getTopScores for Classic mode..."
curl "$BASE_URL/getTopScores?game=Emoji%20Tapper&mode=Classic&platform=iOS&period=all_time&limit=10"

echo ""
echo ""

# Test 3: Get top scores for Penguin Ball mode
echo "3️⃣ Testing getTopScores for Penguin Ball mode..."
curl "$BASE_URL/getTopScores?game=Emoji%20Tapper&mode=Penguin%20Ball&platform=macOS&period=all_time&limit=10"

echo ""
echo ""

# Test 4: Get leaderboard stats
echo "4️⃣ Testing getLeaderboardStats..."
curl "$BASE_URL/getLeaderboardStats?game=Emoji%20Tapper&mode=Penguin%20Ball&platform=macOS"

echo ""
echo ""

# Test 5: Test with different platforms
echo "5️⃣ Testing with macOS platform..."
curl "$BASE_URL/getTopScores?game=Emoji%20Tapper&mode=Classic&platform=macOS&period=all_time&limit=5"

echo ""
echo ""

# Test 6: Test with watchOS platform
echo "6️⃣ Testing with watchOS platform..."
curl "$BASE_URL/getTopScores?game=Emoji%20Tapper&mode=Classic&platform=watchOS&period=all_time&limit=5"

echo ""
echo ""

# Test 7: Test without platform (should fail)
echo "7️⃣ Testing without platform parameter (should fail)..."
curl "$BASE_URL/getTopScores?game=Emoji%20Tapper&mode=Classic&period=all_time&limit=5"

echo ""
echo ""

# Test 8: Get player best
echo "8️⃣ Testing getPlayerBest..."
curl "$BASE_URL/getPlayerBest?game=Emoji%20Tapper&mode=Penguin%20Ball&platform=macOS&player=Josh"

echo ""
echo ""
echo "✅ Debug tests complete!"
