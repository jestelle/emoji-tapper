// Check Firestore database contents
// Run with: node check-firestore.js

const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./service-account-key.json'); // You'll need to download this from Firebase Console
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkFirestore() {
  console.log('🔍 Checking Firestore database...\n');

  try {
    // Get all documents in the highscores collection
    const snapshot = await db.collection('highscores').get();
    
    console.log(`📊 Total documents in highscores collection: ${snapshot.size}\n`);
    
    if (snapshot.empty) {
      console.log('❌ No documents found in highscores collection');
      return;
    }

    // Group by game/mode/platform
    const grouped = {};
    
    snapshot.forEach(doc => {
      const data = doc.data();
      const key = `${data.game || 'unknown'}|${data.mode || 'unknown'}|${data.platform || 'unknown'}`;
      
      if (!grouped[key]) {
        grouped[key] = [];
      }
      grouped[key].push({
        id: doc.id,
        ...data
      });
    });

    console.log('📋 Documents grouped by game|mode|platform:\n');
    
    Object.keys(grouped).forEach(key => {
      const [game, mode, platform] = key.split('|');
      const docs = grouped[key];
      
      console.log(`🎮 ${game} | ${mode} | ${platform} (${docs.length} scores):`);
      docs.forEach(doc => {
        console.log(`   - ${doc.player}: ${doc.score} (${doc.datetime?.toDate?.() || doc.datetime})`);
      });
      console.log('');
    });

    // Test specific queries
    console.log('🧪 Testing specific queries:\n');
    
    // Query for Classic mode
    const classicQuery = await db.collection('highscores')
      .where('game', '==', 'Emoji Tapper')
      .where('mode', '==', 'Classic')
      .get();
    console.log(`Classic mode scores: ${classicQuery.size}`);
    
    // Query for iOS platform
    const iosQuery = await db.collection('highscores')
      .where('game', '==', 'Emoji Tapper')
      .where('platform', '==', 'iOS')
      .get();
    console.log(`iOS platform scores: ${iosQuery.size}`);
    
    // Query for Classic + iOS
    const classicIosQuery = await db.collection('highscores')
      .where('game', '==', 'Emoji Tapper')
      .where('mode', '==', 'Classic')
      .where('platform', '==', 'iOS')
      .get();
    console.log(`Classic + iOS scores: ${classicIosQuery.size}`);

  } catch (error) {
    console.error('❌ Error checking Firestore:', error);
  }
}

checkFirestore().then(() => {
  console.log('✅ Check complete');
  process.exit(0);
}).catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});
