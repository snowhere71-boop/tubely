function PlayIcon() {
  return (
    <svg viewBox="0 0 48 48" width="48" height="48" aria-hidden="true">
      <circle cx="24" cy="24" r="22.5" fill="rgba(21,19,22,0.72)" stroke="var(--color-accent)" strokeWidth="1.5" />
      <path d="M19 15L33 24L19 33V15Z" fill="var(--color-accent)" />
    </svg>
  );
}

export default function VideoCard({ video, isSaved, onPlay, onAddToPlaylist, onRemoveFromPlaylist }) {
  return (
    <div className="video-card">
      <button className="thumb-wrap" onClick={() => onPlay(video)} aria-label={`Play ${video.title}`}>
        <img src={video.thumbnail} alt="" loading="lazy" />
        <span className="play-overlay">
          <PlayIcon />
        </span>
      </button>
      <div className="video-info">
        <h3 title={video.title}>{video.title}</h3>
        <p className="channel">{video.channelTitle}</p>
      </div>
      <button
        className={isSaved ? 'save-btn saved' : 'save-btn'}
        onClick={() => (isSaved ? onRemoveFromPlaylist(video.videoId) : onAddToPlaylist(video))}
      >
        {isSaved ? 'Saved' : 'Save'}
      </button>
    </div>
  );
}
