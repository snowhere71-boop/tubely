import VideoCard from './VideoCard.jsx';

export default function Playlist({ playlist, onPlay, onRemove }) {
  if (!playlist.length) {
    return <p className="status">Nothing saved yet. Add videos from Search.</p>;
  }

  return (
    <div className="grid">
      {playlist.map((video) => (
        <VideoCard
          key={video.videoId}
          video={video}
          isSaved
          onPlay={onPlay}
          onAddToPlaylist={() => {}}
          onRemoveFromPlaylist={onRemove}
        />
      ))}
    </div>
  );
}
