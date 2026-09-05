import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;
import 'config.dart';

class YoutubeApiService {
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();

  Future<List<yt_lib.Video>> searchVideos(String query) async {
    // 1. Try fetching via Backend API first
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<yt_lib.Video> results = [];

        for (var item in data) {
          try {
            final video = await _yt.videos.get(item['id'] ?? item['videoId']);
            results.add(video);
          } catch (_) {}
        }

        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      // Fallback to direct client search if backend is unreachable
    }

    // 2. Direct client fallback
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
