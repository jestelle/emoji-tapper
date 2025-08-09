#!/bin/bash

# Add test data to Firebase Functions
# Run this to populate the database with test data

BASE_URL="https://us-central1-top-leaderboard.cloudfunctions.net"

echo "📝 Adding test data to Firebase..."

# iOS Classic scores
echo "Adding iOS Classic scores..."
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"iOS","player":"Alice","score":150}'
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"iOS","player":"Bob","score":200}'
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"iOS","player":"Charlie","score":175}'

# iOS Penguin Ball scores
echo "Adding iOS Penguin Ball scores..."
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Penguin Ball","platform":"iOS","player":"Alice","score":85}'
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Penguin Ball","platform":"iOS","player":"Bob","score":120}'

# macOS Classic scores
echo "Adding macOS Classic scores..."
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"macOS","player":"Dave","score":180}'
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"macOS","player":"Eve","score":220}'

# macOS Penguin Ball scores
echo "Adding macOS Penguin Ball scores..."
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Penguin Ball","platform":"macOS","player":"Dave","score":95}'

# watchOS Classic scores
echo "Adding watchOS Classic scores..."
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"watchOS","player":"Frank","score":100}'
curl -X POST "$BASE_URL/submitScore" -H "Content-Type: application/json" -d '{"game":"Emoji Tapper","mode":"Classic","platform":"watchOS","player":"Grace","score":125}'

echo ""
echo "✅ Test data added!"
echo ""
echo "Now run: ./debug-api.sh"
