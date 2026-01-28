import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api/userProfile_service.dart';
import '../../../core/services/api/social_service.dart';
import '../../../core/services/api/invite_service.dart';
import '../../../core/utils/user_provider.dart';

import '../../landing/model/socials.dart';
import '../landing_widgets/profile_widgets/inventory_asset_resolver.dart';
import '../model/userInventory.dart';
import '../model/userProfile.dart';
import 'inventory_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();
  final SocialService _socialService = SocialService();
  final InviteService _inviteService = InviteService();


  int inviteEarnings = 0;
  bool inviteLoading = false;

  UserProfile? userProfile;
  Uint8List? profilePictureBytes;
  Social? userSocial;

  bool isLoading = true;
  String? error;

  bool _disposed = false;

  String? _avatarFrameAsset;
  String? get avatarFrameAsset => _avatarFrameAsset;

  get partnerUser => null;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // ===============================
  // RESET (call on logout OR before switching user)
  // ===============================
  void reset() {
    userProfile = null;
    profilePictureBytes = null;
    userSocial = null;
    _avatarFrameAsset = null;

    isLoading = true;
    error = null;

    safeNotify();
  }

  // Optional helper (do not use if you already attach listeners in the page)
  void bindInventory(ItemViewModel itemVM) {
    syncFromInventory(itemVM.inventory);

    // NOTE: If you use this, ensure you don't also attach a listener in ProfilePage
    itemVM.addListener(() {
      syncFromInventory(itemVM.inventory);
    });
  }

  // ===============================
  // 🔥 INVENTORY → PROFILE SYNC
  // ===============================
  void syncFromInventory(List<UserInventoryItem> inventory) {
    debugPrint("🧩 [ProfileVM] syncFromInventory");

    UserInventoryItem? frame;

    for (final i in inventory) {
      if (i.equipped && i.sku.toUpperCase().contains('FRAME')) {
        frame = i;
        break;
      }
    }

    if (frame == null) {
      _avatarFrameAsset = null;
      safeNotify();
      return;
    }

    _avatarFrameAsset = (frame.assetType != null && frame.assetKey != null)
        ? InventoryAssetResolver.fromKey(
      assetType: frame.assetType,
      assetKey: frame.assetKey!,
    )
        : null;

    safeNotify();
  }

  Future<void> updateProfile(
      BuildContext context, {
        String? username,
        String? bio,
        String? birthday,
        List<String>? album,
      }) async {
    if (userProfile == null || _disposed) {
      debugPrint(
        '[ProfileViewModel][updateProfile] aborted '
            'userProfile=$userProfile disposed=$_disposed',
      );
      return;
    }

    debugPrint('[ProfileViewModel][updateProfile] START');
    debugPrint('[ProfileViewModel][updateProfile] userIdentification='
        '${userProfile!.userIdentification}');
    debugPrint('[ProfileViewModel][updateProfile] payload => '
        'username=$username | bio=${bio != null ? bio.length : null} '
        '| birthday=$birthday | albumCount=${album?.length}');

    try {
      final result = await _profileService.updateProfile(
        userIdentification: context.read<UserProvider>().currentUser!.userIdentification,
        username: username,
        bio: bio,
        birthday: birthday,
        album: album,
      );

      debugPrint('[ProfileViewModel][updateProfile] API SUCCESS');

      userProfile = result.profile;
      debugPrint('[ProfileViewModel][updateProfile] profile updated');

      if (result.username != null) {
        context.read<UserProvider>().updateUsername(result.username!);
        debugPrint('[ProfileViewModel][updateProfile] username synced '
            '(${result.username})');
      }

      safeNotify();
      debugPrint('[ProfileViewModel][updateProfile] notifyListeners()');

    } catch (e, s) {
      debugPrint('[ProfileViewModel][updateProfile] ERROR: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    } finally {
      debugPrint('[ProfileViewModel][updateProfile] END');
    }
  }



  // ===============================
  // LOAD PROFILE
  // ===============================
  Future<void> loadProfile(BuildContext context) async {
    if (_disposed) return;

    isLoading = true;
    error = null;

    // ✅ critical: clear previous user's cached state immediately
    userProfile = null;
    profilePictureBytes = null;
    userSocial = null;
    _avatarFrameAsset = null;

    safeNotify();

    try {
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        error = "No logged in user";
        isLoading = false;
        safeNotify();
        return;
      }

      final id = currentUser.userIdentification;

      final profile =
      await _profileService.getProfileByUserIdentification(id);

      userProfile = profile ??
          UserProfile(
            userIdentification: id,
            bio: "",
            profilePicture: null,
          );

      // ✅ if user has no picture, keep bytes null (prevents old user photo leak)
      if (userProfile!.profilePicture?.isNotEmpty == true) {
        profilePictureBytes = await _profileService.fetchProfilePicture(id);
      }

      await fetchSocialData(id);
    } catch (e) {
      error = "Failed to load profile: $e";
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  Future<void> fetchSocialData(String userId) async {
    try {
      final social = await _socialService.fetchSocialData(userId);
      if (_disposed) return;

      if (social != null) {
        userSocial = social;
        safeNotify();
      }
    } catch (_) {}
  }

  Future<void> changeProfilePicture(
      BuildContext context,
      File imageFile,
      ) async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    try {
      final updated = await _profileService.uploadProfilePicture(
        currentUser.userIdentification,
        imageFile,
      );

      if (_disposed || updated == null) return;

      userProfile = updated;
      profilePictureBytes = await _profileService.fetchProfilePicture(
        currentUser.userIdentification,
      );

      safeNotify();
    } catch (e) {
      debugPrint("❌ Failed to update picture: $e");
    }
  }

  // ===============================
  // 🔑 INVITE EARNINGS (FIXED)
  // ===============================
  Future<void> fetchInviteEarnings(BuildContext context) async {
    if (_disposed) return;

    inviteLoading = true;
    safeNotify();

    try {
      final userProvider = context.read<UserProvider>();
      final token = userProvider.token;

      if (token == null) {
        inviteEarnings = 0;
        return;
      }

      final earned =
      await _inviteService.fetchInviteEarnings(userIdentification: userProvider.currentUser!.userIdentification,);

      inviteEarnings = earned;
    } catch (_) {
      inviteEarnings = 0;
    } finally {
      inviteLoading = false;
      safeNotify();
    }
  }
}