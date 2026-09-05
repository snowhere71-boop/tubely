import { get, set } from 'idb-keyval';

const PLAYLIST_KEY = 'tubely-playlist';

export async function getPlaylist() {
  const playlist = await get(PLAYLIST_KEY);
  return playlist || [];
}

export async function addToPlaylist(video) {
  const playlist = await getPlaylist();
  if (playlist.some((v) => v.videoId === video.videoId)) {
    return playlist;
  }
  const updated = [...playlist, video];
  await set(PLAYLIST_KEY, updated);
  return updated;
}

export async function removeFromPlaylist(videoId) {
  const playlist = await getPlaylist();
  const updated = playlist.filter((v) => v.videoId !== videoId);
  await set(PLAYLIST_KEY, updated);
  return updated;
}
