import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api/auth_service.dart';
import '../../features/auth/model/auth_response.dart';
import '../../features/auth/model/auth.dart';
import '../services/api/socket_service.dart';
import 'dart:typed_data';

class UserProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  User? currentUser;
  String? _token;
  bool isLoading = true;

  final _userController = StreamController<User>.broadcast();
  Stream<User> get userStream => _userController.stream;

  late SocketService _socketService;
  bool _socketInitialized = false;

  SocketService get socketService => _socketService;

  String? get token => _token;
  bool get isLoggedIn => currentUser != null && _token != null;
  Uint8List? profilePictureBytes;
  String? profilePictureUrl;

  void updateUsername(String newUsername) {
    currentUser!.username = newUsername;
    notifyListeners();
  }


  void setProfilePictureBytes(Uint8List bytes) {
    profilePictureBytes = bytes;
    notifyListeners();
  }

  void setProfilePictureUrl(String url) {
    profilePictureUrl = url;
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      _token = await _storage.read(key: "auth_token");
      if (_token == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _authService.authCheck(_token!);

      // 🚫 Ban detection
      if (response['error'] == "Account banned") {
        await logout();
        isLoading = false;
        notifyListeners();
        return;
      }

      final userData = response['user'];
      if (userData == null) {
        await logout();
        return;
      }

      currentUser = User.fromJson(userData);
      _userController.add(currentUser!);

      _initSocketIfNeeded(currentUser!.id);

    } catch (e) {
      debugPrint("User load failed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  void _initSocketIfNeeded(String userId) {
    if (_socketInitialized) return;

    _socketService = SocketService();
    _socketService.initSocket(userId);

    // Listen to socket streams
    _socketService.coinsStream.listen((newCoins) {
      updateCoins(newCoins);
    });

    _socketService.diamondsStream.listen((newDiamonds) {
      if (currentUser != null) {
        currentUser!.diamonds = newDiamonds;
        _userController.add(currentUser!);
        notifyListeners();
      }
    });

    _socketInitialized = true;
  }


  Future<void> setUser(AuthResponse authResponse) async {
    _token = authResponse.token;
    currentUser = authResponse.user;
    await _storage.write(key: "auth_token", value: _token);
    _userController.add(currentUser!);
    _initSocketIfNeeded(currentUser!.id);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      debugPrint("Logout failed: $e");
    } finally {
      await _storage.delete(key: "auth_token");
      _token = null;
      currentUser = null;
      if (_socketInitialized) {
        _socketService.dispose();
        _socketInitialized = false;
      }
      _userController.addStream(Stream.empty());
      notifyListeners();
    }
  }

  void updateCoins(int newCoins) {
    if (currentUser == null) return;

    currentUser!.coins = newCoins; // Directly update
    _userController.add(currentUser!);
    notifyListeners();
  }

  void updateDiamonds(int newDiamonds) {
    if (currentUser == null) return;

    currentUser!.diamonds = newDiamonds;
    _userController.add(currentUser!); // ✅ ADD THIS
    notifyListeners();
  }
  void updateVip({
    required int vipLevel,
    required String vipCode,
    required String vipTitle,
    required List<String> vipPerks,
    required double vipTotalRechargeAmount,
    required dynamic vipLastUpdatedAt,
    required bool vipConquerorEntryPermit,
    required bool vipKingsOfKingsEntryTicket,
  }) {
    if (currentUser == null) return;

    currentUser!.vipLevel = vipLevel;
    currentUser!.vipCode = vipCode;
    currentUser!.vipTitle = vipTitle;
    currentUser!.vipPerks = vipPerks;
    currentUser!.vipTotalRechargeAmount = vipTotalRechargeAmount;
    currentUser!.vipLastUpdatedAt = vipLastUpdatedAt;
    currentUser!.vipConquerorEntryPermit = vipConquerorEntryPermit;
    currentUser!.vipKingsOfKingsEntryTicket = vipKingsOfKingsEntryTicket;

    _userController.add(currentUser!);
    notifyListeners();
  }

  void updateVipProgress(Map<String, dynamic> progress) {
    if (currentUser == null) return;

    currentUser!.vipProgress = progress;
    _userController.add(currentUser!);
    notifyListeners();
  }


  @override
  void dispose() {
    if (_socketInitialized) _socketService.dispose();
    _userController.close();
    super.dispose();
  }
}
