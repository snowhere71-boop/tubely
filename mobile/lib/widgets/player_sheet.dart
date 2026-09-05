import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;
import '../models/video.dart';

class PlayerSheet extends StatefulWidget {
  final Video video;
  final List<Video> queue;
  final int initialIndex;

  const PlayerSheet({
    super.key,
    required this.video,
    this.queue = const [],
    this.initialIndex = 0,
  });

  @override
  State<PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<PlayerSheet> {
  late AudioPlayer _audioPlayer;
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _setupQueueAndPlay();
  }

  Future<void> _setupQueueAndPlay() async {
    try {
      List<Video> trackQueue = widget.queue.isNotEmpty ? widget.queue : [widget.video];

      for (var track in trackQueue) {
        var manifest = await _yt.videos.streamsClient.getManifest(track.videoId);
        var audioStream = manifest.audioOnly.withHighestBitrate();

        await _playlist.add(
          AudioSource.uri(audioStream.url),
        );
      }

      await _audioPlayer.setAudioSource(_playlist, initialIndex: _currentIndex);
      _audioPlayer.play();

      _audioPlayer.currentIndexStream.listen((index) {
        if (index != null && mounted) {
          setState(() => _currentIndex = index);
        }
      });
    } catch (e) {
      debugPrint("Error initializing playback: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> activeList = widget.queue.isNotEmpty ? widget.queue : [widget.video];
    Video currentTrack = activeList.length > _currentIndex ? activeList[_currentIndex] : widget.video;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              currentTrack.thumbnailUrl,
              height: 220,
              width: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                width: 220,
                color: Colors.grey[850],
                child: const Icon(Icons.music_note, size: 80, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Metadata
          Text(
            currentTrack.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            currentTrack.channelTitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Controls
          _isLoading
              ? const CircularProgressIndicator(color: Colors.amber)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: _audioPlayer.hasPrevious ? () => _audioPlayer.seekToPrevious() : null,
                    ),
                    const SizedBox(width: 16),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing ?? false;
                        return IconButton(
                          iconSize: 64,
                          icon: Icon(
                            playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            if (playing) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _audioPlayer.hasNext ? () => _audioPlayer.seekToNext() : null,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
