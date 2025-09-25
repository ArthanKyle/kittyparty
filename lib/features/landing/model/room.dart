import 'package:kittyparty/features/landing/model/userProfile.dart';

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
  final DateTime createdAt;
  final String? hostProfilePic;

  Room({
    this.id,
    required this.hostId,
    required this.roomName,
    this.topic = "",
    this.type = "public",
    this.maxParticipants = 8,
    this.participantsCount = 1,
    required this.country,
    this.isActive = true,
    this.zegoRoomId,
    DateTime? createdAt,
    this.hostProfilePic, // ✅ added here
  }) : createdAt = createdAt ?? DateTime.now();

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['_id'] as String?,
    hostId: json['HostID'] as String,
    roomName: json['RoomName'] as String,
    topic: json['Topic'] as String? ?? "",
    type: json['Type'] as String? ?? "public",
    maxParticipants: json['MaxParticipants'] as int? ?? 8,
    participantsCount: json['ParticipantsCount'] as int? ?? 1,
    country: json['Country'] as String? ?? "",
    isActive: json['IsActive'] as bool? ?? true,
    zegoRoomId: json['ZegoRoomId'] as String?,
    createdAt: json['CreatedAt'] != null
        ? DateTime.parse(json['CreatedAt'])
        : DateTime.now(),
    hostProfilePic: json['HostProfilePic'] as String?, // ✅ maps from JSON
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'HostID': hostId,
    'RoomName': roomName,
    'Topic': topic,
    'Type': type,
    'MaxParticipants': maxParticipants,
    'ParticipantsCount': participantsCount,
    'Country': country,
    'IsActive': isActive,
    'ZegoRoomId': zegoRoomId,
    'CreatedAt': createdAt.toIso8601String(),
    'HostProfilePic': hostProfilePic, // ✅ include in serialization
  };

  /// Helper method to inject host profile info from a UserProfile
  Room withHostProfile(UserProfile profile) {
    return Room(
      id: id,
      hostId: hostId,
      roomName: roomName,
      topic: topic,
      type: type,
      maxParticipants: maxParticipants,
      participantsCount: participantsCount,
      country: country,
      isActive: isActive,
      zegoRoomId: zegoRoomId,
      createdAt: createdAt,
      hostProfilePic: profile.profilePicture, // ✅ sync with UserProfile
    );
  }
}
