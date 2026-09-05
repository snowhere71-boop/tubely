import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;

class PlayerSheet extends StatefulWidget {
  final yt_lib.Video video;

  const PlayerSheet({
    super.key,
    required this.video,
  });

  @override
  State<PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<PlayerSheet> {
  late AudioPlayer _audioPlayer;
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // 1. Fetch stream manifest from youtube_explode_dart
      var manifest = await _yt.videos.streamsClient.getManifest(widget.video.id);
      
      // 2. Safely pick the best available audio-only stream
      var audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) {
        throw Exception("No audio-only streams available");
      }
      
      var audioStream = audioStreams.withHighestBitrate();

      // 3. Set audio URL with custom headers to prevent 403 Forbidden errors from YouTube CDN
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioStream.url.toString()),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
      if (mounted) setState(() => _hasError = true);
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.video.thumbnails.highResUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                width: 200,
                color: Colors.grey[850],
                child: const Icon(Icons.music_note, size: 80, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.video.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            widget.video.author,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.amber)
          else if (_hasError)
            Column(
              children: [
                const Text(
                  "Failed to load audio source",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _initAudio();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.amber),
                  label: const Text("Retry", style: TextStyle(color: Colors.amber)),
                ),
              ],
            )
          else
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
        ],
      ),
    );
  }
}
