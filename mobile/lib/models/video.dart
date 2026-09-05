class Video {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnail;

  const Video({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['videoId'] as String,
      title: json['title'] as String? ?? '',
      channelTitle: json['channelTitle'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'channelTitle': channelTitle,
        'thumbnail': thumbnail,
      };
}
