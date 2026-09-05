import 'package:flutter/material.dart';
import '../models/video.dart';
import '../services/youtube_api.dart';
import '../services/playlist_store.dart';
import '../widgets/video_grid.dart';
import '../widgets/player_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _api = YoutubeApi();
  final _playlistStore = PlaylistStore();
  final _searchController = TextEditingController();

  late TabController _tabController;

  List<Video> _results = [];
  List<Video> _playlist = [];
  bool _hasSearched = false;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  String? _nextPageToken;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlaylist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylist() async {
    final playlist = await _playlistStore.load();
    if (!mounted) return;
    setState(() => _playlist = playlist);
  }

  Future<void> _search(String query, {bool append = false}) async {
    if (query.trim().isEmpty) return;

    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });

    try {
      final result = await _api.search(query, pageToken: append ? _nextPageToken : null);
      if (!mounted) return;
      setState(() {
        _results = append ? [..._results, ...result.videos] : result.videos;
        _nextPageToken = result.nextPageToken;
        _hasSearched = true;
        _query = query;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        if (!append) _results = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  bool _isSaved(String videoId) => _playlist.any((v) => v.videoId == videoId);

  Future<void> _toggleSave(Video video) async {
    final playlist = _isSaved(video.videoId)
        ? await _playlistStore.remove(video.videoId)
        : await _playlistStore.add(video);
    if (!mounted) return;
    setState(() => _playlist = playlist);
  }

  void _openPlayer(Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerSheet(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUBELY'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF2A93B),
          labelColor: const Color(0xFFF5F1E8),
          unselectedLabelColor: const Color(0xFF9C96A3),
          tabs: [
            const Tab(text: 'Search'),
            Tab(text: _playlist.isEmpty ? 'My Playlist' : 'My Playlist (${_playlist.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _search(value),
              decoration: const InputDecoration(
                hintText: 'Search YouTube…',
                prefixIcon: Icon(Icons.search, color: Color(0xFF9C96A3)),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                VideoGrid(
                  results: _results,
                  loading: _loading,
                  loadingMore: _loadingMore,
                  error: _error,
                  hasSearched: _hasSearched,
                  query: _query,
                  hasMore: _nextPageToken != null,
                  isSaved: _isSaved,
                  onPlay: _openPlayer,
                  onToggleSave: _toggleSave,
                  onLoadMore: () => _search(_query, append: true),
                ),
                VideoGrid(
                  results: _playlist,
                  loading: false,
                  loadingMore: false,
                  error: null,
                  hasSearched: true,
                  query: '',
                  hasMore: false,
                  isSaved: (_) => true,
                  onPlay: _openPlayer,
                  onToggleSave: _toggleSave,
                  onLoadMore: () {},
                  emptyMessage: 'Nothing saved yet. Add videos from Search.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
