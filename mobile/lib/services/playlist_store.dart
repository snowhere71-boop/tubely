import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';

class PlaylistStore {
  static const _key = 'tubely_playlist';

  Future<List<Video>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => Video.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<List<Video>> add(Video video) async {
    final current = await load();
    if (current.any((v) => v.videoId == video.videoId)) return current;
    final updated = [...current, video];
    await _save(updated);
    return updated;
  }

  Future<List<Video>> remove(String videoId) async {
    final current = await load();
    final updated = current.where((v) => v.videoId != videoId).toList();
    await _save(updated);
    return updated;
  }

  Future<void> _save(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = videos.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
