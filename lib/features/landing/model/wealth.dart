class WealthStatus {
  final int level;
  final int exp;
  final int nextLevel;
  final int nextLevelTotalRequired;
  final int remainingToNext;
  final double percentToNext;
  final bool badgeUnlocked;
  final bool entryEffectUnlocked;

  WealthStatus({
    required this.level,
    required this.exp,
    required this.nextLevel,
    required this.nextLevelTotalRequired,
    required this.remainingToNext,
    required this.percentToNext,
    required this.badgeUnlocked,
    required this.entryEffectUnlocked,
  });

  factory WealthStatus.fromJson(Map<String, dynamic> j) {
    return WealthStatus(
      level: (j['level'] ?? 1) as int,
      exp: (j['exp'] ?? 0) as int,
      nextLevel: (j['nextLevel'] ?? ((j['level'] ?? 1) as int)) as int,
      nextLevelTotalRequired: (j['nextLevelTotalRequired'] ?? 0) as int,
      remainingToNext: (j['remainingToNext'] ?? 0) as int,
      percentToNext: ((j['percentToNext'] ?? 0.0) as num).toDouble(),
      badgeUnlocked: (j['badgeUnlocked'] ?? true) as bool,
      entryEffectUnlocked: (j['entryEffectUnlocked'] ?? false) as bool,
    );
  }
}
