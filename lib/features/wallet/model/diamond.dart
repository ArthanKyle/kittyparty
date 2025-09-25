class Diamond {
  int diamonds;

  Diamond({required this.diamonds});

  factory Diamond.fromJson(Map<String, dynamic> json) {
    final raw = json['Diamonds'];
    return Diamond(
      diamonds: (raw is int)
          ? raw
          : int.tryParse(raw?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Diamonds': diamonds,
  };
}