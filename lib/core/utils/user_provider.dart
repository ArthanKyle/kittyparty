import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api/auth_service.dart';
import '../../features/auth/model/auth_response.dart';
import '../../features/auth/model/auth.dart';
import '../services/api/socket_service.dart';

class UserProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  User? currentUser;
  String? _token;
  bool isLoading = true;
  late SocketService socketService;

  // Stream for real-time updates
  final _userController = StreamController<User>.broadcast();
  Stream<User> get userStream => _userController.stream;

  String? get token => _token;
  bool get isLoggedIn => currentUser != null && _token != null;

  /// Initialize socket with callback for real-time coin updates
  void initSocket(String userId) {
    socketService = SocketService();
    socketService.initSocket(userId, (newCoins) {
      updateCoins(newCoins); // automatically update coins
    });
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

      if (response['user'] != null) {
        currentUser = User.fromJson(response['user']);

        // Emit initial user
        _userController.add(currentUser!);

        // 🔥 Initialize socket for real-time updates automatically
        initSocket(currentUser!.id);
        debugPrint("💰 Loaded user coins: ${currentUser!.coins}");
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint("User load failed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(AuthResponse authResponse) async {
    _token = authResponse.token;
    currentUser = authResponse.user;
    await _storage.write(key: "auth_token", value: _token);
    _userController.add(currentUser!);
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
      _userController.addStream(Stream.empty());
      notifyListeners();
    }
  }

  void updateCoins(int newCoins) {
    if (currentUser == null) return;
    currentUser = User(
      id: currentUser!.id,
      userIdentification: currentUser!.userIdentification,
      fullName: currentUser!.fullName,
      email: currentUser!.email,
      phoneNumber: currentUser!.phoneNumber,
      loginMethod: currentUser!.loginMethod,
      passwordHash: currentUser!.passwordHash,
      countryCode: currentUser!.countryCode,
      vipLevel: currentUser!.vipLevel,
      coins: newCoins, // 👈 updated here
      diamonds: currentUser!.diamonds,
      status: currentUser!.status,
      dateJoined: currentUser!.dateJoined,
      lastLogin: currentUser!.lastLogin,
      invitationCode: currentUser!.invitationCode,
      username: currentUser!.username,
    );
    _userController.add(currentUser!);
    notifyListeners();
  }

  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }

}
