class GameConfig {
  final int sceneMode;
  final String currencyIcon;

  GameConfig({required this.sceneMode, required this.currencyIcon});

  Map<String, dynamic> toJson() => {
    "sceneMode": sceneMode,
    "currencyIcon": currencyIcon,
  };
}

class GetConfigData {
  final String appChannel;
  final int appId;
  final String userId;
  final String gameMode;
  final String language;
  final int gsp;
  final String roomId;
  final String code;
  final GameConfig gameConfig;
  final double balance;

  GetConfigData({
    required this.appChannel,
    required this.appId,
    required this.userId,
    required this.gameMode,
    required this.language,
    required this.gsp,
    required this.roomId,
    required this.code,
    required this.gameConfig,
    this.balance = 0.0,
  });

  Map<String, dynamic> toJson() => {
    "appChannel": appChannel,
    "appId": appId,
    "userId": userId,
    "gameMode": gameMode,
    "language": language,
    "gsp": gsp,
    "roomId": roomId,
    "code": code,
    "balance": balance, // Include balance
    "gameConfig": gameConfig.toJson(),
  };
}