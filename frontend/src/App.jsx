import { useEffect, useState, useCallback } from 'react';
import SearchBar from './components/SearchBar.jsx';
import ResultsGrid from './components/ResultsGrid.jsx';
import VideoPlayer from './components/VideoPlayer.jsx';
import Playlist from './components/Playlist.jsx';
import { getPlaylist, addToPlaylist, removeFromPlaylist } from './utils/playlistStore.js';

const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

export default function App() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [hasSearched, setHasSearched] = useState(false);
  const [nextPageToken, setNextPageToken] = useState(null);
  const [loading, setLoading] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState(null);
  const [activeVideo, setActiveVideo] = useState(null);
  const [playlist, setPlaylist] = useState([]);
  const [activeTab, setActiveTab] = useState('search');

  useEffect(() => {
    getPlaylist().then(setPlaylist);
  }, []);

  const runSearch = useCallback(async (term, pageToken, append) => {
    if (!term.trim()) return;

    if (append) setLoadingMore(true);
    else setLoading(true);
    setError(null);

    try {
      const params = new URLSearchParams({ q: term });
      if (pageToken) params.set('pageToken', pageToken);

      const res = await fetch(`${API_BASE}/search?${params.toString()}`);
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Search failed');

      setResults((prev) => (append ? [...prev, ...data.results] : data.results));
      setNextPageToken(data.nextPageToken);
      setHasSearched(true);
    } catch (err) {
      setError(err.message);
      if (!append) setResults([]);
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  }, []);

  const handleSearch = (term) => {
    setQuery(term);
    setActiveTab('search');
    runSearch(term, null, false);
  };

  const handleLoadMore = () => {
    if (nextPageToken) runSearch(query, nextPageToken, true);
  };

  const handleAddToPlaylist = async (video) => {
    setPlaylist(await addToPlaylist(video));
  };

  const handleRemoveFromPlaylist = async (videoId) => {
    setPlaylist(await removeFromPlaylist(videoId));
  };

  const playlistIds = new Set(playlist.map((v) => v.videoId));

  return (
    <div className="app">
      <header className="app-header">
        <span className="brand">Tubely</span>
        <SearchBar onSearch={handleSearch} />
      </header>

      <nav className="tabs">
        <button
          className={activeTab === 'search' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('search')}
        >
          Search
        </button>
        <button
          className={activeTab === 'playlist' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('playlist')}
        >
          My Playlist{playlist.length > 0 ? ` (${playlist.length})` : ''}
        </button>
      </nav>

      <main className="app-main">
        {activeTab === 'search' && (
          <ResultsGrid
            results={results}
            loading={loading}
            loadingMore={loadingMore}
            error={error}
            hasSearched={hasSearched}
            query={query}
            hasMore={Boolean(nextPageToken)}
            playlistIds={playlistIds}
            onPlay={setActiveVideo}
            onLoadMore={handleLoadMore}
            onAddToPlaylist={handleAddToPlaylist}
            onRemoveFromPlaylist={handleRemoveFromPlaylist}
          />
        )}

        {activeTab === 'playlist' && (
          <Playlist playlist={playlist} onPlay={setActiveVideo} onRemove={handleRemoveFromPlaylist} />
        )}
      </main>

      {activeVideo && <VideoPlayer video={activeVideo} onClose={() => setActiveVideo(null)} />}
    </div>
  );
}
