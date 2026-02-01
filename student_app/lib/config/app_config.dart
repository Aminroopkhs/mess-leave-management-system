import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get backendUrl {
    final url = Platform.isAndroid
        ? dotenv.env['BACKEND_URL_ANDROID']
        : dotenv.env['BACKEND_URL_OTHERS'];

    if (url == null || url.isEmpty) {
      throw Exception(
        "BACKEND_URL is not set. Check your .env or dart-define.",
      );
    }
    return url;
  }
}
