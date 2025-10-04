import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
class GeminiFlashService {
  static const String _modelId = 'gemini-2.0-flash-exp';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent';
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  static final RateLimiter _limiter = RateLimiter(
    maxRequests: 60,
    timeWindow: const Duration(minutes: 1),
  );

  Future<String> getFreeResponse(String input) async {
    await _limiter.throttle();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: _buildOptimizedPayload(input),
      ).timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  String _buildOptimizedPayload(String input) {
    return jsonEncode({
      'contents': [{
        'parts': [{'text': _compressPrompt(input)}]
      }],
      'generationConfig': {
        'maxOutputTokens': 1024,
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    });
  }

  String _compressPrompt(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        if (data['candidates']?.isNotEmpty == true &&
            data['candidates'][0]['content']?.isNotEmpty == true) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        throw Exception('Empty response from API');
      case 429:
        throw Exception('Rate limit exceeded');
      case 403:
        throw Exception('API key quota exceeded');
      case 400:
        throw Exception('Invalid request');
      default:
        throw Exception('API Error: ${response.statusCode}');
    }
  }
}

class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final Queue<DateTime> _requestTimes = Queue();

  RateLimiter({required this.maxRequests, required this.timeWindow});

  Future<void> throttle() async {
    final now = DateTime.now();
    while (_requestTimes.isNotEmpty && 
           now.difference(_requestTimes.first) > timeWindow) {
      _requestTimes.removeFirst();
    }
    
    if (_requestTimes.length >= maxRequests) {
      final waitTime = timeWindow - now.difference(_requestTimes.first);
      await Future.delayed(waitTime);
    }
    
    _requestTimes.add(now);
  }
}

