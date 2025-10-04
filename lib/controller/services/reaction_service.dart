import 'dart:async';
import 'dart:convert';

import 'package:blyft/models/article_model.dart';
import 'package:blyft/controller/services/backend_service.dart' as backend;
import 'package:blyft/controller/services/auth_service.dart' as auth;
import 'package:blyft/utils/logger.dart';
import 'package:http/http.dart' as http;

class _ReactionRequest {
  final Article article;
  final String action; // 'like', 'dislike', 'remove_like', 'remove_dislike'

  _ReactionRequest(this.article, this.action);
}

/// Queue that serializes reaction API calls (one at a time).
class ReactionQueue {
  static final ReactionQueue _instance = ReactionQueue._internal();
  factory ReactionQueue() => _instance;
  ReactionQueue._internal();

  final List<_ReactionRequest> _queue = [];
  bool _processing = false;

  // Map article.url -> backend articleId (returned when article is created on first like/dislike)
  final Map<String, String> _articleIdMap = {};
  // Track which URLs are liked/disliked (populated from server on preload)
  final Set<String> _likedUrls = {};
  final Set<String> _dislikedUrls = {};
  bool _loaded = false;

  void enqueueLike(Article article) {
    _enqueue(_ReactionRequest(article, 'like'));
  }

  void enqueueDislike(Article article) {
    _enqueue(_ReactionRequest(article, 'dislike'));
  }

  void enqueueRemoveLike(Article article) {
    _enqueue(_ReactionRequest(article, 'remove_like'));
  }

  void enqueueRemoveDislike(Article article) {
    _enqueue(_ReactionRequest(article, 'remove_dislike'));
  }

  void _enqueue(_ReactionRequest req) {
    _queue.add(req);
    if (!_processing) {
      _processNext();
    }
  }

  Future<void> _processNext() async {
    if (_queue.isEmpty) {
      _processing = false;
      return;
    }

    _processing = true;
    final req = _queue.removeAt(0);

    try {
      switch (req.action) {
        case 'like':
          await _sendLike(req.article);
          break;
        case 'dislike':
          await _sendDislike(req.article);
          break;
        case 'remove_like':
          await _sendRemoveLike(req.article);
          break;
        case 'remove_dislike':
          await _sendRemoveDislike(req.article);
          break;
        default:
          Log.w('Unknown reaction action: ${req.action}');
      }
    } catch (e, st) {
      Log.e('Reaction request failed: $e\n$st');
      // Swallow errors to keep UI smooth per requirements
    }

    // Process next in queue
    // Slight delay to avoid hammering server when user rapidly toggles
    await Future.delayed(const Duration(milliseconds: 80));
    _processNext();
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
  // Prefer token from AuthService since app stores it there; fallback to ApiService
  final token = auth.AuthService().accessToken ?? backend.ApiService().accessToken;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _sendLike(Article article) async {
  final uri = Uri.parse('${backend.ApiService.baseUrl}/reactions/like');
    final body = article.toJson();

  final resp = await http.post(uri, headers: _buildHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      try {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final articleId = decoded['data']?['articleId']?.toString();
        if (articleId != null) {
          _articleIdMap[article.url] = articleId;
        }
  // Update local sets so UI can reflect persisted state
  _likedUrls.add(article.url);
  _dislikedUrls.remove(article.url);
      } catch (e) {
        // ignore malformed response
      }
    } else {
      Log.w('Like API returned ${resp.statusCode}');
    }
  }

  Future<void> _sendDislike(Article article) async {
  final uri = Uri.parse('${backend.ApiService.baseUrl}/reactions/dislike');
    final body = article.toJson();

    final resp = await http.post(uri, headers: _buildHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      try {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final articleId = decoded['data']?['articleId']?.toString();
        if (articleId != null) {
          _articleIdMap[article.url] = articleId;
        }
  _dislikedUrls.add(article.url);
  _likedUrls.remove(article.url);
      } catch (e) {
        // ignore malformed response
      }
    } else {
      Log.w('Dislike API returned ${resp.statusCode}');
    }
  }

  Future<void> _sendRemoveLike(Article article) async {
    final articleId = _articleIdMap[article.url];
    if (articleId == null) {
      return;
    }

  final uri = Uri.parse('${backend.ApiService.baseUrl}/reactions/like/$articleId');
    final resp = await http.delete(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      // Optionally remove mapping
  _articleIdMap.remove(article.url);
  _likedUrls.remove(article.url);
    } else {
      Log.w('Remove like API returned ${resp.statusCode}');
    }
  }

  Future<void> _sendRemoveDislike(Article article) async {
    final articleId = _articleIdMap[article.url];
    if (articleId == null) return;

  final uri = Uri.parse('${backend.ApiService.baseUrl}/reactions/dislike/$articleId');
    final resp = await http.delete(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      _articleIdMap.remove(article.url);
      _dislikedUrls.remove(article.url);
    } else {
      Log.w('Remove dislike API returned ${resp.statusCode}');
    }
  }

  /// Fetch reacted news from backend and populate local liked/disliked sets.
  Future<void> preloadReactions() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final uri = Uri.parse('${backend.ApiService.baseUrl}/reactions/reacted-news');
      final resp = await http.get(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        final reactions = data?['reactions'] as List<dynamic>?;
        if (reactions != null) {
          for (final r in reactions) {
            try {
              final item = r as Map<String, dynamic>;
              final url = item['url']?.toString();
                  final articleId = item['articleId']?.toString();
              final type = item['reactionType']?.toString();
              if (url == null || type == null) continue;
                  if (articleId != null) {
                    _articleIdMap[url] = articleId;
                  }
              if (type == 'like') {
                _likedUrls.add(url);
                _dislikedUrls.remove(url);
              } else if (type == 'dislike') {
                _dislikedUrls.add(url);
                _likedUrls.remove(url);
              }
            } catch (e) {
              // ignore malformed reaction entry
            }
          }
        }
      } else {
        Log.w('Preload reacted-news returned ${resp.statusCode}');
      }
    } catch (e, st) {
      Log.e('Failed to preload reactions: $e\n$st');
    }
  }

  bool isArticleLiked(String url) => _likedUrls.contains(url);
  bool isArticleDisliked(String url) => _dislikedUrls.contains(url);
}

