import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/global_widgets/dialogs/dialog_info.dart';
import '../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../core/utils/profile_picture_helper.dart';
import '../../core/utils/user_provider.dart';
import '../landing/viewmodel/profile_viewmodel.dart';

class EditPersonalInformationPage extends StatefulWidget {
  final ProfileViewModel vm;

  const EditPersonalInformationPage({
    super.key,
    required this.vm,
  });

  @override
  State<EditPersonalInformationPage> createState() =>
      _EditPersonalInformationPageState();
}

class _EditPersonalInformationPageState
    extends State<EditPersonalInformationPage> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  DateTime? birthday;

  ProfileViewModel get vm => widget.vm;

  @override
  void initState() {
    super.initState();

    final user = context
        .read<UserProvider>()
        .currentUser!;
    final profile = vm.userProfile;

    _nicknameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: profile?.bio ?? "");

    birthday = profile?.birthday != null
        ? DateTime.tryParse(profile!.birthday!)
        : null;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  InputDecoration _borderedInput({
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context
        .read<UserProvider>()
        .currentUser!;
    final profile = vm.userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Personal Information",
          style: TextStyle(color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        children: [
          // ================= AVATAR =================
          ListTile(
            title: const Text("Avatar"),
            trailing: UserAvatarHelper.circleAvatar(
              userIdentification: user.userIdentification,
              displayName: _nicknameController.text,
              radius: 22,
              localBytes: vm.profilePictureBytes,
              frameAsset: vm.avatarFrameAsset,
            ),
            onTap: () => _changeAvatar(context),
          ),

          // ================= NICKNAME (INLINE + BORDER) =================
          ListTile(
            title: const Text("Nickname"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _nicknameController,
                maxLength: 20,
                decoration: _borderedInput(hint: "Enter nickname"),
              ),
            ),
          ),

          // ================= BIRTHDAY =================
          ListTile(
            title: const Text("Birthday"),
            trailing: Text(
              birthday != null
                  ? "${birthday!.year}-${birthday!.month.toString().padLeft(
                  2, '0')}-${birthday!.day.toString().padLeft(2, '0')}"
                  : "—",
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: _editBirthday,
          ),

          // ================= AREA =================
          ListTile(
            title: const Text("Area"),
            trailing: Text(
              user.countryCode,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          // ================= BIO (INLINE + BORDER) =================
          ListTile(
            title: const Text("Personal Introduction"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 150,
                decoration:
                _borderedInput(hint: "Tell something about yourself"),
              ),
            ),
          ),

          const Divider(height: 32),

          // ================= UPDATE BUTTON =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newNickname = _nicknameController.text.trim();
                  final newBio = _bioController.text.trim();

                  // 1️⃣ Show loading
                  DialogLoading(
                    subtext: "Updating profile...",
                    willPop: false,
                  ).build(context);

                  try {
                    // 2️⃣ Perform async action
                    await vm.updateProfile(
                      context,
                      username: newNickname != user.username ? newNickname : null,
                      bio: newBio != profile?.bio ? newBio : null,
                      birthday: birthday != null
                          ? "${birthday!.year}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}"
                          : null,
                      album: profile?.album,
                    );

                    // 3️⃣ Close loading dialog
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    // 4️⃣ Show success dialog
                    DialogInfo(
                      headerText: "Success",
                      subText: "Your profile has been updated successfully.",
                      confirmText: "OK",
                      onCancel: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pop(context);
                      },
                    ).build(context);
                  } catch (e) {
                    // 5️⃣ Close loading dialog
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    // 6️⃣ Show error dialog
                    DialogInfo(
                      headerText: "Update Failed",
                      subText: e.toString(),
                      confirmText: "OK",
                      onCancel: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ).build(context);
                  }
                },
                child: const Text(
                  "Update Information",
                  style: TextStyle(color: AppColors.accentWhite),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BIRTHDAY =================

  Future<void> _editBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => birthday = picked);
    }
  }

  // ================= AVATAR =================

  Future<void> _changeAvatar(BuildContext context) async {
    final picker = ImagePicker();

    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Avatar',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Adjust Avatar',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    // 🔹 Remove previous avatar immediately
    setState(() {
      vm.profilePictureBytes = null;
    });

    // 🔹 Show loading dialog
    DialogLoading(
      subtext: "Uploading avatar...",
      willPop: false,
    ).build(context);

    try {
      await vm.changeProfilePicture(context, File(cropped.path));
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
      }
    }
  }
}