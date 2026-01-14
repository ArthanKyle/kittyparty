import "dart:convert";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:kittyparty/core/services/api/room_income_service.dart";

import "../../../features/landing/model/transaction_txn.dart";

class TransactionsApi {
  TransactionsApi({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? dotenv.env["BASE_URL"] ?? "").trim(),
        _client = client ?? http.Client() {
    if (this.baseUrl.isEmpty) {
      throw Exception("BASE_URL is missing.");
    }
  }

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final b = Uri.parse(baseUrl);
    final cleanBasePath = b.path.endsWith("/") ? b.path.substring(0, b.path.length - 1) : b.path;
    final cleanPath = path.startsWith("/") ? path : "/$path";

    return Uri(
      scheme: b.scheme,
      host: b.host,
      port: b.hasPort ? b.port : null,
      path: "$cleanBasePath$cleanPath",
      queryParameters: query,
    );
  }

  Future<List<RechargeTxn>> getRechargeHistory({
    required String userId,
  }) async {

    final res = await _client.get(_uri("/recharge/user-history/$userId"));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Recharge history failed: ${res.statusCode} ${res.body}");
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <RechargeTxn>[];
    return data.map((e) => RechargeTxn.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RoomIncomeSummary> getRoomIncomeSummary({
    required String roomId,
  }) async {
    final res = await _client.get(_uri("/room-income/rooms/$roomId/income/summary"));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Room income summary failed: ${res.statusCode} ${res.body}");
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw Exception("Unexpected summary response");
    }

    return RoomIncomeSummary.fromJson(data);
  }
}
