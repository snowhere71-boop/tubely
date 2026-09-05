import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;
import 'config.dart';

class YoutubeApiService {
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();

  Future<List<yt_lib.Video>> searchVideos(String query) async {
    // 1. Fetch search results from Render backend
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<yt_lib.Video> results = [];

        for (var item in data) {
          try {
            final String? videoId = item['id']?['videoId'] ?? item['id'] ?? item['videoId'];
            if (videoId != null) {
              final video = await _yt.videos.get(videoId);
              results.add(video);
            }
          } catch (_) {}
        }

        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      // Backend fallback
    }

    // 2. Direct package fallback if Render response is empty
    try {
      final searchList = await _yt.search.getVideos(query);
      return searchList.toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }
}
