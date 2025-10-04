class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;
  final String sourceName;
  final String author;
  final String content;
  final String timeAgo;
  final String imagePlaceholder;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    required this.author,
    required this.content,
    required this.timeAgo,
    this.imagePlaceholder = 'assets/images/news_placeholder.png',
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final publishedAt = DateTime.parse(json['publishedAt'] ?? DateTime.now().toString());
    
    return Article(
      title: json['title'] ?? 'Interesting News',
      description: json['description'] ?? 'Read more about this developing story',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: publishedAt,
      sourceName: json['source'] != null ? json['source']['name'] : json['sourceName'] ?? 'Unknown Source',
      author: json['author'] ?? 'Staff Writer',
      content: json['content'] ?? 'Content not available',
      timeAgo: _getTimeAgo(publishedAt),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'sourceName': sourceName,
      'author': author,
      'content': content,
      'timeAgo': timeAgo,
    };
  }

  static String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${(difference.inDays / 7).floor()}w ago';
  }
}

