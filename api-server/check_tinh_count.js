import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Initialize Firebase Admin
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkTinhCount() {
  try {
    console.log('🔍 Checking Tinh collection...\n');
    
    const snapshot = await db.collection('tinh').get();
    console.log(`📊 Total documents in 'tinh': ${snapshot.size}`);
    
    if (snapshot.size > 0) {
      console.log('\n📝 Sample documents:');
      let count = 0;
      snapshot.forEach(doc => {
        if (count < 10) { // Show first 10
          console.log(`  - ID ${doc.id}: ${doc.data().name}`);
          count++;
        }
      });
      
      if (snapshot.size > 10) {
        console.log(`  ... and ${snapshot.size - 10} more documents`);
      }
    }
    
    console.log('\n✅ Check complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkTinhCount();
