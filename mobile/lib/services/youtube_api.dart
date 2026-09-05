import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;

class YoutubeApiService {
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();

  Future<List<yt_lib.Video>> searchVideos(String query) async {
    try {
      // Query YouTube search client directly
      final searchList = await _yt.search.getVideos(query);
      return searchList.toList();
    } catch (e) {
      // Fallback search mechanism if getVideos encounters client blocks
      try {
        final searchList = await _yt.search.search(query);
        return searchList.toList();
      } catch (innerError) {
        return [];
      }
    }
  }

  void dispose() {
    _yt.close();
  }
}
