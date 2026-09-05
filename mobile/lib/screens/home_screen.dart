ListTile(
  // ... your existing video card title, thumbnail, etc. ...
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerSheet(video: video),
    );
  },
)
