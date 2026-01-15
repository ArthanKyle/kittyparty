import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/gift_transaction.dart';

class GiftTransactionService {
  final String baseUrl = dotenv.env["BASE_URL"]!;

  Future<List<GiftTransaction>> getUserGiftTransactions(
      String userIdentification, {
        int limit = 50,
      }) async {
    final uri = Uri.parse(
      "$baseUrl/gifts/transactions/user/$userIdentification?limit=$limit",
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        "Gift transactions HTTP ${res.statusCode}: ${res.body}",
      );
    }

    final decoded = jsonDecode(res.body);

    final List list = decoded is Map<String, dynamic>
        ? (decoded["data"] as List? ?? [])
        : [];

    return list
        .map((e) => GiftTransaction.fromJson(e))
        .toList();
  }
}
