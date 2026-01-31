class GameConfigModel {
  String? appChannel;
  String? appId;
  String? userId;
  String? code;
  String? roomId;
  int? gameMode;
  int? language;
  int? gsp;
  GameConfigConfig? gameConfig;
  //All parameters must be added!!!!

  GameConfigModel({
    this.appChannel,
    this.appId,
    this.userId,
    this.code,
    this.roomId,
    this.gameMode,
    this.language,
    this.gsp,
    this.gameConfig,
  });

  factory GameConfigModel.fromJson(Map<String, dynamic> source) {
    return GameConfigModel(
      appChannel: source['appChannel'] as String,
      appId: source['appId'] as String,
      userId: source['userId'] as String,
      code: source['code'] as String,
      roomId: source['roomId'] as String,
      gameMode: source['gameMode'] as int,
      language: source['language'] as int,
      gsp: source['gsp'] as int,
      gameConfig: GameConfigConfig.fromJson(source['gameConfig']),
    );
  }

  Map<String, dynamic> toJson() => {
    'appChannel': appChannel,
    'appId': appId,
    'userId': userId,
    'code': code,
    'roomId': roomId,
    'gameMode': gameMode,
    'language': language,
    'gsp': gsp,
    'gameConfig': gameConfig!.toJson(),
  };
}

class GameConfigConfig {
  int? sceneMode;
  String? currencyIcon;

  GameConfigConfig({
    this.sceneMode,
    this.currencyIcon,
  });

  factory GameConfigConfig.fromJson(Map<String, dynamic> source) {
    return GameConfigConfig(
      sceneMode: source['sceneMode'] as int,
      currencyIcon: source['currencyIcon'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'sceneMode': sceneMode,
    'currencyIcon': currencyIcon,
  };
}
