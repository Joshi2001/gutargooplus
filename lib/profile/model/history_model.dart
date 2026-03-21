class HistoryModel {
  final String title;
  final String subtitle;
  final String image;
  final DateTime watchedAt;

  HistoryModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.watchedAt,
  });

  String getTimeAgo() {
    final diff = DateTime.now().difference(watchedAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}
