class Room {
  final String? id;
  final String hostId;
  final String roomName;
  final String topic;
  final String type;
  final int maxParticipants;
  final int participantsCount;
  final String country;
  final bool isActive;
  final String? zegoRoomId;
  final String? roomIdentification;   // <-- NEW FIELD
  final DateTime createdAt;
  final String? hostProfilePic;
  final int onlineCount;
  final int audienceCount;
  final int usersCount;


  Room({
    this.id,
    required this.hostId,
    required this.roomName,
    this.topic = "",
    this.type = "public",
    this.maxParticipants = 8,
    this.participantsCount = 1,
    this.onlineCount = 0,
    this.audienceCount = 0,
    this.usersCount = 0,
    required this.country,
    this.isActive = true,
    this.zegoRoomId,
    this.roomIdentification,          // <-- NEW
    DateTime? createdAt,
    this.hostProfilePic,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['_id'] as String?,
    hostId: json['HostID'] as String,
    roomName: json['RoomName'] as String,
    topic: json['Topic'] ?? "",
    type: json['Type'] ?? "public",
    onlineCount: json['onlineCount'] ?? 0,
    audienceCount: json['audienceCount'] ?? 0,
    usersCount: json['usersCount'] ?? 0,
    maxParticipants: json['MaxParticipants'] ?? 8,
    participantsCount: json['ParticipantsCount'] ?? 1,
    country: json['Country'] ?? "",
    isActive: json['IsActive'] ?? true,
    zegoRoomId: json['ZegoRoomId'],
    roomIdentification: json['RoomIdentification'],   // <-- NEW
    createdAt: json['CreatedAt'] != null
        ? DateTime.parse(json['CreatedAt'])
        : DateTime.now(),
    hostProfilePic: json['HostProfilePic'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'HostID': hostId,
    'RoomName': roomName,
    'Topic': topic,
    'Type': type,
    'onlineCount': onlineCount,
    'audienceCount': audienceCount,
    'usersCount': usersCount,
    'MaxParticipants': maxParticipants,
    'ParticipantsCount': participantsCount,
    'Country': country,
    'IsActive': isActive,
    'ZegoRoomId': zegoRoomId,
    'RoomIdentification': roomIdentification,  // <-- NEW
    'CreatedAt': createdAt.toIso8601String(),
    'HostProfilePic': hostProfilePic,
  };
}
