class User {
  final String id; // MongoDB _id
  final String userIdentification;
  final String username;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String loginMethod;
  final String? passwordHash;
  final String countryCode;

  // ✅ add gender (boy/girl)
  final String gender; // "boy" | "girl"

  final int vipLevel;
  int coins;
  int diamonds;
  final String status;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final String? invitationCode;
  bool isFirstTimeRecharge;
  final String? myInvitationCode;

  User({
    required this.id,
    required this.userIdentification,
    required this.username,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.loginMethod,
    this.passwordHash,
    required this.countryCode,

    // ✅ gender
    this.gender = "girl",

    this.vipLevel = 0,
    this.coins = 0,
    this.diamonds = 0,
    this.status = "offline",
    DateTime? dateJoined,
    this.lastLogin,
    this.invitationCode,
    this.isFirstTimeRecharge = true,
    this.myInvitationCode,
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

    email: json['Email'] ?? json['email'],
    phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'],
    loginMethod: json['LoginMethod'] ?? json['loginMethod'] ?? "Email",
    passwordHash: json['PasswordHash'] ?? json['passwordHash'],
    countryCode: json['CountryCode'] ?? json['countryCode'] ?? "",

    // ✅ gender mapping (accepts boy/girl, male/female, m/f, 1/2)
    gender: _parseGender(
      json['Gender'] ??
          json['gender'] ??
          json['Sex'] ??
          json['sex'] ??
          json['isMale'] ??
          json['IsMale'],
    ),

    vipLevel: (json['VIPLevel'] is int)
        ? json['VIPLevel']
        : int.tryParse(json['VIPLevel']?.toString() ?? "0") ?? 0,
    coins: (json['Coins'] is int)
        ? json['Coins']
        : (json['coins'] is int)
        ? json['coins']
        : int.tryParse(
      json['Coins']?.toString() ??
          json['coins']?.toString() ??
          "0",
    ) ??
        0,
    diamonds: (json['Diamonds'] is int)
        ? json['Diamonds']
        : int.tryParse(json['Diamonds']?.toString() ?? "0") ?? 0,
    status: json['Status'] ?? json['status'] ?? "offline",
    dateJoined: json['DateJoined'] != null
        ? DateTime.parse(json['DateJoined'])
        : DateTime.now(),
    lastLogin: json['LastLogin'] != null
        ? DateTime.parse(json['LastLogin'])
        : null,
    invitationCode: json['InvitationCode'] ?? json['invitationCode'],
    isFirstTimeRecharge: json['isFirstTimeRecharge'] ?? true,
    myInvitationCode: json['MyInvitationCode'] ?? json['myInvitationCode'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'UserIdentification': userIdentification,
    'Username': username,
    'FullName': fullName,
    'Email': email,
    'PhoneNumber': phoneNumber,
    'LoginMethod': loginMethod,
    'PasswordHash': passwordHash,
    'CountryCode': countryCode,

    // ✅ include gender for backend
    'Gender': gender,

    'VIPLevel': vipLevel,
    'Coins': coins,
    'Diamonds': diamonds,
    'Status': status,
    'DateJoined': dateJoined.toIso8601String(),
    'LastLogin': lastLogin?.toIso8601String(),
    if (invitationCode != null) 'InvitationCode': invitationCode,
    'isFirstTimeRecharge': isFirstTimeRecharge,
    if (myInvitationCode != null) 'MyInvitationCode': myInvitationCode,
  };

  // --------------------
  // helpers
  // --------------------
  static String _parseGender(dynamic raw) {
    if (raw == null) return "girl";

    // bool style: isMale true/false
    if (raw is bool) return raw ? "boy" : "girl";

    final v = raw.toString().trim().toLowerCase();

    // numeric style
    if (v == '1') return "boy";
    if (v == '2') return "girl";

    // string style
    if (v == 'boy' || v == 'male' || v == 'm') return "boy";
    if (v == 'girl' || v == 'female' || v == 'f') return "girl";

    return "girl";
  }
}
