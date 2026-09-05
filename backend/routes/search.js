import express from 'express';

const router = express.Router();
const YOUTUBE_SEARCH_URL = 'https://www.googleapis.com/youtube/v3/search';

router.get('/search', async (req, res) => {
  const { q, maxResults, pageToken } = req.query;

  if (!q || !q.trim()) {
    return res.status(400).json({ error: 'Missing required query parameter: q' });
  }

  const apiKey = process.env.YOUTUBE_API_KEY;
  if (!apiKey) {
    return res.status(500).json({
      error: 'Server is missing YOUTUBE_API_KEY. Add it to backend/.env and restart the server.',
    });
  }

  const params = new URLSearchParams({
    part: 'snippet',
    type: 'video',
    q,
    maxResults: String(Math.min(Number(maxResults) || 12, 50)),
    key: apiKey,
  });
  if (pageToken) params.set('pageToken', String(pageToken));

  try {
    const ytResponse = await fetch(`${YOUTUBE_SEARCH_URL}?${params.toString()}`);
    const data = await ytResponse.json();

    if (!ytResponse.ok) {
      const message = data?.error?.message || 'YouTube API request failed';
      return res.status(ytResponse.status).json({ error: message });
    }

    const results = (data.items || [])
      .filter((item) => item.id && item.id.videoId)
      .map((item) => ({
        videoId: item.id.videoId,
        title: item.snippet.title,
        description: item.snippet.description,
        channelTitle: item.snippet.channelTitle,
        publishedAt: item.snippet.publishedAt,
        thumbnail:
          item.snippet.thumbnails?.medium?.url ||
          item.snippet.thumbnails?.default?.url ||
          '',
      }));

    res.json({
      results,
      nextPageToken: data.nextPageToken || null,
      prevPageToken: data.prevPageToken || null,
    });
  } catch (err) {
    console.error('YouTube search error:', err);
    res.status(502).json({ error: 'Could not reach the YouTube API. Try again in a moment.' });
  }
});

export default router;
