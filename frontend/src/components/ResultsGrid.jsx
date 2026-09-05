import VideoCard from './VideoCard.jsx';

export default function ResultsGrid({
  results,
  loading,
  loadingMore,
  error,
  hasSearched,
  query,
  hasMore,
  playlistIds,
  onPlay,
  onLoadMore,
  onAddToPlaylist,
  onRemoveFromPlaylist,
}) {
  if (loading) return <p className="status">Searching…</p>;
  if (error) return <p className="status error">Couldn't complete that search: {error}</p>;

  if (!hasSearched) {
    return <p className="status">Search above to find videos.</p>;
  }

  if (!results.length) {
    return <p className="status">No results for "{query}". Try a different search.</p>;
  }

  return (
    <>
      <div className="grid">
        {results.map((video) => (
          <VideoCard
            key={video.videoId}
            video={video}
            isSaved={playlistIds.has(video.videoId)}
            onPlay={onPlay}
            onAddToPlaylist={onAddToPlaylist}
            onRemoveFromPlaylist={onRemoveFromPlaylist}
          />
        ))}
      </div>
      {hasMore && (
        <button className="load-more" onClick={onLoadMore} disabled={loadingMore}>
          {loadingMore ? 'Loading…' : 'Load more'}
        </button>
      )}
    </>
  );
}
