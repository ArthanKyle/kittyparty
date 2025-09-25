import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZegoConfig {
  static int get appID => int.parse(dotenv.env['ZEGO_APP_ID']!);
  static String get appSign => dotenv.env['ZEGO_APP_SIGN']!;
}