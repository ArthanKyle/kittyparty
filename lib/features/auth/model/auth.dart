class User {
  final String id; // MongoDB _id
  final String userIdentification;
  String username;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String loginMethod;
  final bool passwordHash;
  final String countryCode;

  // gender: male | female
  final String gender;

  // VIP (single source of truth)
  int vipLevel;
  String vipCode;
  String vipTitle;
  List<String> vipPerks;
  double vipTotalRechargeAmount;
  DateTime? vipLastUpdatedAt;
  bool vipConquerorEntryPermit;
  bool vipKingsOfKingsEntryTicket;

  final int wealthLevel;

  int coins;
  int diamonds;

  final String status;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final String? invitationCode;
  bool isFirstTimeRecharge;
  final String? myInvitationCode;
  Map<String, dynamic>? vipProgress;

  User({
    required this.id,
    required this.userIdentification,
    required this.username,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.loginMethod,
    required this.passwordHash,
    required this.countryCode,
    required this.gender,

    // VIP
    this.vipLevel = 0,
    this.vipCode = '',
    this.vipTitle = '',
    List<String>? vipPerks,
    this.vipTotalRechargeAmount = 0,
    this.vipLastUpdatedAt,
    this.vipConquerorEntryPermit = false,
    this.vipKingsOfKingsEntryTicket = false,
    this.vipProgress,

    this.coins = 0,
    this.diamonds = 0,
    this.status = "offline",
    DateTime? dateJoined,
    this.lastLogin,
    this.invitationCode,
    this.isFirstTimeRecharge = true,
    this.myInvitationCode,
    this.wealthLevel = 0,
  }) :  vipPerks = vipPerks ?? [],
        dateJoined = dateJoined ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      userIdentification:
      json['UserIdentification']?.toString() ??
          json['userIdentification']?.toString() ??
          '',
      username:
      json['Username']?.toString() ??
          json['username']?.toString() ??
          '',
      fullName:
      json['FullName']?.toString() ??
          json['fullName']?.toString() ??
          '',
      email: json['Email'] ?? json['email'],
      phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'],
      loginMethod: json['LoginMethod'] ?? json['loginMethod'] ?? 'Email',
      passwordHash: json['passwordHash'] == true, // ✅ read bool
      countryCode:
      json['CountryCode'] ??
          json['countryCode'] ??
          json['country'] ??
          '',
      gender: _parseGender(json['Gender'] ?? json['gender']),
      vipLevel: json['vipLevel'] is int
          ? json['vipLevel']
          : int.tryParse(json['vipLevel']?.toString() ?? '0') ?? 0,
      wealthLevel: json['wealthLevel'] is int
          ? json['wealthLevel']
          : int.tryParse(json['wealthLevel']?.toString() ?? '0') ?? 0,
      coins: json['Coins'] ?? json['coins'] ?? 0,
      diamonds: json['Diamonds'] ?? json['diamonds'] ?? 0,
      status: json['Status'] ?? json['status'] ?? 'offline',
      dateJoined: json['DateJoined'] != null
          ? DateTime.parse(json['DateJoined'])
          : DateTime.now(),
      lastLogin: json['LastLogin'] != null
          ? DateTime.parse(json['LastLogin'])
          : null,
      invitationCode:
      json['InvitationCode'] ?? json['invitationCode'],
      isFirstTimeRecharge: json['isFirstTimeRecharge'] ?? true,
      myInvitationCode:
      json['MyInvitationCode'] ?? json['myInvitationCode'],
      vipCode: json['vipCode'] ?? '',
      vipTitle: json['vipTitle'] ?? '',
      vipPerks: json['vipPerks'] is List
          ? List<String>.from(json['vipPerks'])
          : [],
      vipTotalRechargeAmount:
      (json['vipTotalRechargeAmount'] as num?)?.toDouble() ?? 0,
      vipLastUpdatedAt: json['vipLastUpdatedAt'] != null
          ? DateTime.tryParse(json['vipLastUpdatedAt'])
          : null,
      vipConquerorEntryPermit:
      json['vipConquerorEntryPermit'] == true,
      vipKingsOfKingsEntryTicket:
      json['vipKingsOfKingsEntryTicket'] == true,
      vipProgress: json['vipProgress'],

    );
  }

  /// Client never sends VIP or wallet values
  Map<String, dynamic> toJson() => {
    '_id': id,
    'UserIdentification': userIdentification,
    'Username': username,
    'FullName': fullName,
    'Email': email,
    'PhoneNumber': phoneNumber,
    'LoginMethod': loginMethod,
    'CountryCode': countryCode,
    'Gender': gender,
    'Status': status,
    'DateJoined': dateJoined.toIso8601String(),
    'LastLogin': lastLogin?.toIso8601String(),
    if (invitationCode != null) 'InvitationCode': invitationCode,
    'isFirstTimeRecharge': isFirstTimeRecharge,
    if (myInvitationCode != null)
      'MyInvitationCode': myInvitationCode,
  };

  static String _parseGender(dynamic raw) {
    if (raw == null) return 'female';

    final v = raw.toString().trim().toLowerCase();

    if (v == 'male' || v == 'm' || v == '1' || v == 'boy') {
      return 'male';
    }

    if (v == 'female' || v == 'f' || v == '2' || v == 'girl') {
      return 'female';
    }

    return 'female';
  }
}
