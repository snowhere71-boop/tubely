import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;
import 'player_sheet.dart';

class VideoGrid extends StatelessWidget {
  final List<yt_lib.Video> videos;

  const VideoGrid({
    super.key,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Center(
        child: Text(
          "No videos found",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PlayerSheet(video: video),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    video.thumbnails.mediumResUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[850],
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                video.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
