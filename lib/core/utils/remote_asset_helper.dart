import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RemoteAssetHelper {
  static final Map<String, File> _memoryCache = {};

  static String get _mediaBaseUrl {
    final url = dotenv.env['MEDIA_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('MEDIA_BASE_URL not set');
    }
    return url;
  }

  /// 🔥 Synchronous read (NO async in widgets)
  static File? cached(String assetPath) {
    return _memoryCache[assetPath];
  }

  /// Load backend asset -> cache locally + memory
  static Future<File> load(String assetPath) async {
    // MEMORY HIT
    if (_memoryCache.containsKey(assetPath)) {
      return _memoryCache[assetPath]!;
    }

    final uri = Uri.parse('$_mediaBaseUrl$assetPath');
    final dir = await getApplicationSupportDirectory();

    final safeName = uri.path.replaceAll('/', '_');
    final file = File('${dir.path}/$safeName');

    // DISK HIT
    if (await file.exists()) {
      _memoryCache[assetPath] = file;
      return file;
    }

    // NETWORK HIT
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception(
        'Asset load failed (${res.statusCode}): $assetPath',
      );
    }

    await file.writeAsBytes(res.bodyBytes);
    _memoryCache[assetPath] = file;
    return file;
  }
}
