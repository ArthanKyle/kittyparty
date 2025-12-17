import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/wallet/model/wallet.dart';

class WalletService {
  final String baseUrl;

  WalletService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Wallet> fetchWallet(String userIdentification) async {
    final url = "$baseUrl/wallet/$userIdentification";

    print("🟡 [WalletService] Fetching wallet");
    print("🟡 [WalletService] URL: $url");

    final res = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    print("🟡 [WalletService] Status code: ${res.statusCode}");
    print("🟡 [WalletService] Raw response: ${res.body}");

    if (res.statusCode != 200) {
      print("🔴 [WalletService] Fetch failed");
      throw Exception("Failed to fetch wallet");
    }

    final data = jsonDecode(res.body);

    final coins = data["coins"] ?? 0;
    final diamonds = data["diamonds"] ?? 0;

    print("🟢 [WalletService] Parsed coins: $coins");
    print("🟢 [WalletService] Parsed diamonds: $diamonds");

    return Wallet(
      coins: coins,
      diamonds: diamonds,
    );
  }
}
