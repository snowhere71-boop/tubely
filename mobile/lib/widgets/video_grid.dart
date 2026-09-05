import 'package:flutter/material.dart';
import '../models/video.dart';

class VideoGrid extends StatelessWidget {
  final List<Video> results;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final bool hasSearched;
  final String query;
  final bool hasMore;
  final bool Function(String videoId) isSaved;
  final void Function(Video video) onPlay;
  final void Function(Video video) onToggleSave;
  final VoidCallback onLoadMore;
  final String emptyMessage;

  const VideoGrid({
    super.key,
    required this.results,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.hasSearched,
    required this.query,
    required this.hasMore,
    required this.isSaved,
    required this.onPlay,
    required this.onToggleSave,
    required this.onLoadMore,
    this.emptyMessage = 'Search above to find videos.',
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF2A93B)));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Couldn't complete that search: $error",
            style: const TextStyle(color: Color(0xFFE0596B)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (!hasSearched) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Color(0xFF9C96A3))),
      );
    }
    if (results.isEmpty) {
      final message =
          query.isEmpty ? emptyMessage : 'No results for "$query". Try a different search.';
      return Center(child: Text(message, style: const TextStyle(color: Color(0xFF9C96A3))));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: results.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          return Center(
            child: TextButton(
              onPressed: loadingMore ? null : onLoadMore,
              child: Text(loadingMore ? 'Loading…' : 'Load more'),
            ),
          );
        }
        final video = results[index];
        return _VideoCard(
          video: video,
          saved: isSaved(video.videoId),
          onPlay: () => onPlay(video),
          onToggleSave: () => onToggleSave(video),
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  final bool saved;
  final VoidCallback onPlay;
  final VoidCallback onToggleSave;

  const _VideoCard({
    required this.video,
    required this.saved,
    required this.onPlay,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2C2830)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onPlay,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black),
                  ),
                  const Center(
                    child: Icon(Icons.play_circle_fill, color: Color(0xFFF2A93B), size: 40),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              video.channelTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF9C96A3), fontSize: 12),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: saved ? const Color(0xFFF2A93B) : const Color(0xFF2C2830),
                  ),
                  foregroundColor: saved ? const Color(0xFFF2A93B) : const Color(0xFFF5F1E8),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: onToggleSave,
                child: Text(saved ? 'Saved' : 'Save', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
