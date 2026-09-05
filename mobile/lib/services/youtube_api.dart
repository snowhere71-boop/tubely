import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;

class YoutubeApiService {
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();

  Future<List<yt_lib.Video>> searchVideos(String query) async {
    try {
      final searchResult = await _yt.search.search(query);
      return searchResult.toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }
}
