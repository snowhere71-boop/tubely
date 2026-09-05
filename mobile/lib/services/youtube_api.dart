import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/video.dart';

class SearchResult {
  final List<Video> videos;
  final String? nextPageToken;
  SearchResult(this.videos, this.nextPageToken);
}

class YoutubeApiException implements Exception {
  final String message;
  YoutubeApiException(this.message);
  @override
  String toString() => message;
}

class YoutubeApi {
  Future<SearchResult> search(String query, {String? pageToken}) async {
    final params = {
      'q': query,
      if (pageToken != null) 'pageToken': pageToken,
    };
    final uri = Uri.parse('$apiBaseUrl/search').replace(queryParameters: params);

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw YoutubeApiException(body['error']?.toString() ?? 'Search failed');
    }

    final items = (body['results'] as List<dynamic>? ?? [])
        .map((item) => Video.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResult(items, body['nextPageToken'] as String?);
  }
}
