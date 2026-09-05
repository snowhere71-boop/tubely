import { useEffect, useRef } from 'react';

// Loads YouTube's own iframe player script — playback, ads, and controls
// stay exactly as YouTube serves them; nothing here modifies the player.
const YT_SCRIPT_SRC = 'https://www.youtube.com/iframe_api';

let apiPromise = null;

function loadYouTubeIframeAPI() {
  if (window.YT && window.YT.Player) {
    return Promise.resolve(window.YT);
  }
  if (apiPromise) return apiPromise;

  apiPromise = new Promise((resolve) => {
    const existingCallback = window.onYouTubeIframeAPIReady;
    window.onYouTubeIframeAPIReady = () => {
      if (typeof existingCallback === 'function') existingCallback();
      resolve(window.YT);
    };

    if (!document.querySelector(`script[src="${YT_SCRIPT_SRC}"]`)) {
      const tag = document.createElement('script');
      tag.src = YT_SCRIPT_SRC;
      document.head.appendChild(tag);
    }
  });

  return apiPromise;
}

export default function useYouTubePlayer(containerId, videoId) {
  const playerRef = useRef(null);

  useEffect(() => {
    let cancelled = false;

    loadYouTubeIframeAPI().then((YT) => {
      if (cancelled) return;

      if (playerRef.current) {
        playerRef.current.loadVideoById(videoId);
        return;
      }

      playerRef.current = new YT.Player(containerId, {
        videoId,
        playerVars: { autoplay: 1 },
      });
    });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [videoId]);

  useEffect(() => {
    return () => {
      if (playerRef.current?.destroy) {
        playerRef.current.destroy();
        playerRef.current = null;
      }
    };
  }, []);
}
