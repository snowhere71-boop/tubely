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
      var manifest = await _yt.videos.streamsClient.getManifest(widget.video.videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();

      await _audioPlayer.setUrl(audioStream.url.toString());
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Error: $e");
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
              widget.video.thumbnailUrl,
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
            widget.video.channelTitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.amber)
          else if (_hasError)
            const Text("Failed to load audio source", style: TextStyle(color: Colors.redAccent))
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
