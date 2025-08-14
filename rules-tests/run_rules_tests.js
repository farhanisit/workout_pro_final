const { initializeTestEnvironment, assertSucceeds, assertFails } =
  require('@firebase/rules-unit-testing');
const { setLogLevel } = require('firebase/firestore');
const fs = require('fs');

async function main() {
  const rules = fs.readFileSync(require('path').join(__dirname,'..','firestore.rules'),'utf8');

  const testEnv = await initializeTestEnvironment({
    projectId: 'demo-workoutpro',
    firestore: { rules }
  });

  setLogLevel('error');

  let failures = 0;
  async function caseRun(name, fn) {
    try {
      await fn();
      console.log('PASS -', name);
    } catch (e) {
      failures++;
      console.error('FAIL -', name, '\n', e?.message || e);
    }
  }

  try {
    await caseRun('owner can create with normalized fields', async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertSucceeds(db.collection('exercises').doc('e1').set({
        userId: 'u1', bodyPart: 'chest', target: 10, createdAt: new Date()
      }));
    });

    await caseRun('deny wrong bodyPart', async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertFails(db.collection('exercises').doc('e2').set({
        userId: 'u1', bodyPart: 'random', target: 10, createdAt: new Date()
      }));
    });

    await caseRun('deny non-int target', async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertFails(db.collection('exercises').doc('e3').set({
        userId: 'u1', bodyPart: 'legs', target: '12'
      }));
    });

    await caseRun('deny cross-user read', async () => {
      const ownerDb = testEnv.authenticatedContext('u1').firestore();
      await ownerDb.collection('exercises').doc('e4')
        .set({ userId:'u1', bodyPart:'back', target:8, createdAt:new Date() });

      const intruderDb = testEnv.authenticatedContext('u2').firestore();
      await assertFails(intruderDb.collection('exercises').doc('e4').get());
    });

    await caseRun('owner can update own doc', async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertSucceeds(db.collection('exercises').doc('e4').update({ target: 9 }));
    });

    await caseRun('intruder cannot update others', async () => {
      const intruderDb = testEnv.authenticatedContext('u2').firestore();
      await assertFails(intruderDb.collection('exercises').doc('e4').update({ target: 99 }));
    });
  } finally {
    await testEnv.cleanup();
  }

  if (failures > 0) process.exitCode = 1;
}

main().catch((e) => {
  console.error('FATAL', e);
  process.exit(1);
});
