class User {
  final String id; // MongoDB _id
  final String userIdentification;
  final String username; // <-- keep this
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String loginMethod;
  final String? passwordHash;
  final String countryCode;
  final int vipLevel;
  int coins;
  int diamonds;
  final String status;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final String? invitationCode;
  bool isFirstTimeRecharge;

  User({
    required this.id,
    required this.userIdentification,
    required this.username,   // <-- make required
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.loginMethod,
    this.passwordHash,
    required this.countryCode,
    this.vipLevel = 0,
    this.coins = 0,
    this.diamonds = 0,
    this.status = "offline",
    DateTime? dateJoined,
    this.lastLogin,
    this.invitationCode,
    this.isFirstTimeRecharge = true,
  }) : dateJoined = dateJoined ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'] ?? json['id'] ?? '',
    userIdentification: json['UserIdentification']?.toString() ??
        json['userIdentification']?.toString() ??
        "",
    username: json['Username']?.toString() ??
        json['username']?.toString() ??
        json['userName']?.toString() ??
        "",
    fullName: json['FullName']?.toString() ??
        json['fullName']?.toString() ??
        "",
    email: json['Email'],
    phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'],
    loginMethod: json['LoginMethod'] ?? "Email",
    passwordHash: json['PasswordHash'],
    countryCode: json['CountryCode'] ?? json['countryCode'] ?? "",
    vipLevel: (json['VIPLevel'] is int)
        ? json['VIPLevel']
        : int.tryParse(json['VIPLevel']?.toString() ?? "0") ?? 0,
    coins: (json['Coins'] is int)
        ? json['Coins']
        : (json['coins'] is int)
        ? json['coins']
        : int.tryParse(json['Coins']?.toString() ??
        json['coins']?.toString() ??
        "0") ??
        0,
    diamonds: (json['Diamonds'] is int)
        ? json['Diamonds']
        : int.tryParse(json['Diamonds']?.toString() ?? "0") ?? 0,
    status: json['Status'] ?? "offline",
    dateJoined: json['DateJoined'] != null
        ? DateTime.parse(json['DateJoined'])
        : DateTime.now(),
    lastLogin: json['LastLogin'] != null
        ? DateTime.parse(json['LastLogin'])
        : null,
    invitationCode: json['InvitationCode'],
    isFirstTimeRecharge: json['isFirstTimeRecharge'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'UserIdentification': userIdentification,
    'Username': username, // <-- Include it here
    'FullName': fullName,
    'Email': email,
    'PhoneNumber': phoneNumber,
    'LoginMethod': loginMethod,
    'PasswordHash': passwordHash,
    'CountryCode': countryCode,
    'VIPLevel': vipLevel,
    'Coins': coins,
    'Diamonds': diamonds,
    'Status': status,
    'DateJoined': dateJoined.toIso8601String(),
    'LastLogin': lastLogin?.toIso8601String(),
    if (invitationCode != null) 'InvitationCode': invitationCode,
    'isFirstTimeRecharge': isFirstTimeRecharge,
  };
}
