import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/logger.dart';
import '../../utils/api_config.dart';
import 'auth_service.dart';

class OAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // add a Server client ID
    // serverClientId: 'the SERVER_CLIENT_ID.apps.googleusercontent.com',
  );
  static Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      Log.i('<OAUTH_SERVICE> Starting Google SDK OAuth flow');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Log.w('<OAUTH_SERVICE> Google sign in cancelled by user');
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Google ID token not available');
      }

      Log.d('<OAUTH_SERVICE> Google ID token obtained, sending to backend');

      // Send the ID token to the backend
      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': googleAuth.idToken, 'accessToken': googleAuth.accessToken}),
      );

      Log.d('<OAUTH_SERVICE> Backend response: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          await AuthService().handleOAuthSuccess(
            accessToken: data['data']['accessToken'],
            refreshToken: data['data']['refreshToken'],
            userData: data['data']['user'],
            context: context,
          );

          Log.i('<OAUTH_SERVICE> Google OAuth completed successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'OAuth authentication failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'OAuth request failed');
      }
    } catch (e) {
      Log.e('<OAUTH_SERVICE> Google OAuth error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Google sign in failed: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return false;
    }
  }

  static Future<bool> signInWithApple(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple OAuth not implemented in backend yet'), backgroundColor: Color(0xFFF59E0B)),
    );
    return false;
  }

  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      Log.i('<OAUTH_SERVICE> Google sign out completed');
    } catch (e) {
      Log.w('<OAUTH_SERVICE> Google sign out error: $e');
    }
  }
}

