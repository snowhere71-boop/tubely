import { useEffect } from 'react';
import useYouTubePlayer from '../hooks/useYouTubePlayer.js';

export default function VideoPlayer({ video, onClose }) {
  const containerId = 'yt-player';
  useYouTubePlayer(containerId, video.videoId);

  useEffect(() => {
    const onKeyDown = (e) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [onClose]);

  return (
    <div
      className="player-overlay"
      role="dialog"
      aria-modal="true"
      aria-label={video.title}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div className="player-panel">
        <div className="player-header">
          <h3>{video.title}</h3>
          <button className="close-btn" onClick={onClose} aria-label="Close player">
            ✕
          </button>
        </div>
        <div className="player-frame">
          <div id={containerId} />
        </div>
      </div>
    </div>
  );
}
