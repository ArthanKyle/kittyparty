import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/wallet/model/wallet.dart';

class WalletService {
  final String baseUrl;

  WalletService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Wallet> fetchWallet(String userIdentification) async {
    final res = await http.get(
      Uri.parse("$baseUrl/wallet/$userIdentification"),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch wallet");
    }

    final data = jsonDecode(res.body);
    return Wallet(
      coins: data["coins"] ?? 0,
      diamonds: data["diamonds"] ?? 0,
    );
  }
}
