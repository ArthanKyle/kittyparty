import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../features/landing/model/banner_item.dart';


class BannerService {
  static String get _baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not set');
    }
    return url;
  }

  static Future<List<BannerItem>> fetchBanners() async {
    final uri = Uri.parse('$_baseUrl/assets/banners');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load banners');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => BannerItem.fromJson(e))
        .where((b) => b.enabled)
        .toList();
  }
}
