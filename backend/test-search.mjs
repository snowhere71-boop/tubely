// Quick smoke test for the backend.
// 1. Start the server in another terminal: npm run dev
// 2. Then run:                             npm test
//
// To test a deployed backend instead of localhost:
//   TEST_BASE_URL=https://your-app.onrender.com npm test

const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:5000';

async function checkHealth() {
  const res = await fetch(`${BASE_URL}/api/health`);
  if (!res.ok) throw new Error(`Health check failed with status ${res.status}`);
  console.log('✔ /api/health responded');
}

async function checkSearch() {
  const res = await fetch(`${BASE_URL}/api/search?q=lofi+hip+hop`);
  const data = await res.json();

  if (!res.ok) {
    throw new Error(`Search failed: ${data.error || res.status}`);
  }

  const valid =
    Array.isArray(data.results) &&
    data.results.length > 0 &&
    data.results.every((v) => v.videoId && v.title && v.thumbnail);

  if (!valid) throw new Error('Search response is missing expected fields');
  console.log(`✔ /api/search returned ${data.results.length} valid results`);
}

async function run() {
  console.log(`Testing backend at ${BASE_URL}\n`);
  await checkHealth();
  await checkSearch();
  console.log('\nAll checks passed.');
}

run().catch((err) => {
  console.error(`✘ ${err.message}`);
  process.exit(1);
});
