import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/utils/user_provider.dart';
import '../../../landing/viewmodel/agency_viewmodel.dart';
import '../../../../core/services/api/agency_service.dart';

class AgencyRegistrationApplicationPage extends StatefulWidget {
  final String title;
  final String initialDisplayName;
  final String initialUserId;
  final bool isCreateAgency;
  final String? agencyCode;

  const AgencyRegistrationApplicationPage({
    super.key,
    required this.title,
    required this.initialDisplayName,
    required this.initialUserId,
    required this.isCreateAgency,
    this.agencyCode,
  });

  @override
  State<AgencyRegistrationApplicationPage> createState() =>
      _AgencyRegistrationApplicationPageState();
}

class _AgencyRegistrationApplicationPageState
    extends State<AgencyRegistrationApplicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _agencyAvatarUrl = TextEditingController();
  final _agencyName = TextEditingController();
  final _agencyDescription = TextEditingController();


  File? _agencyLogoFile;

  @override
  void dispose() {
    _agencyAvatarUrl.dispose();
    _agencyName.dispose();
    _agencyDescription.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    final ownerPhone = [
      user?.countryCode ?? '',
      user?.phoneNumber ?? '',
    ].join();

    final vm = context.watch<AgencyViewModel>();
    final isBusy = vm.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _TopUserCard(
                name: widget.initialDisplayName,
                id: widget.initialUserId,
              ),
              const SizedBox(height: 14),

              /// ✅ AGENCY LOGO
              _ImagePickerBox(
                label: "Agency Avatar",
                controller: _agencyAvatarUrl,
                requiredField: false,
                onPicked: (file) => _agencyLogoFile = file,
              ),

              const SizedBox(height: 14),

              _TextRowField(
                label: "Agency Name*",
                hint: "Please enter",
                controller: _agencyName,
                requiredField: true,
              ),

              const SizedBox(height: 10),

              _TextRowField(
                label: "Description",
                hint: "Optional",
                controller: _agencyDescription,
                requiredField: false,
              ),

              const SizedBox(height: 10),

              _ReadOnlyRow(
                label: "Owner Contact Number",
                value: ownerPhone,
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1B36B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ======================================================
   * SUBMIT — MATCHES ViewModel EXACTLY
   * ====================================================== */
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmCompleter = Completer<bool>();

    // 1️⃣ SHOW CONFIRMATION
    DialogInfo(
      headerText: "Create Agency",
      subText: "Would you like to create this agency?",
      confirmText: "Create",
      cancelText: "Cancel",
      onConfirm: () {
        Navigator.of(context).pop();
        confirmCompleter.complete(true);
      },
      onCancel: () {
        Navigator.of(context).pop();
        confirmCompleter.complete(false);
      },
    ).build(context);

    final confirm = await confirmCompleter.future;
    if (confirm != true) return;

    final vm = context.read<AgencyViewModel>();

    AgencyLogoUpload? logo;

    if (_agencyLogoFile != null) {
      final bytes = await _agencyLogoFile!.readAsBytes();
      logo = AgencyLogoUpload(
        bytes: bytes,
        filename: _agencyLogoFile!.path.split('/').last,
        mimeType: "image/jpeg",
      );
    }

    // 2️⃣ SHOW LOADING
    DialogLoading(
      subtext: "Creating agency...",
    ).build(context);

    bool ok = false;
    String message = "Failed to create agency.";

    try {
      ok = await vm.createAgency(
        name: _agencyName.text.trim(),
        description: _agencyDescription.text.trim(),
        logo: logo,
      );

      if (ok) {
        message = "Agency created successfully.";
      }
    } catch (e) {
      message = e.toString();
    }

    if (!mounted) return;

    // 3️⃣ CLOSE LOADING
    Navigator.of(context).pop();

    // 4️⃣ RESULT DIALOG
    final resultCompleter = Completer<void>();

    DialogInfo(
      headerText: ok ? "Success" : "Notice",
      subText: message,
      confirmText: "OK",
      onConfirm: () {
        Navigator.of(context).pop();
        resultCompleter.complete();
      },
      onCancel: () {
        Navigator.of(context).pop();
        resultCompleter.complete();
      },
    ).build(context);

    await resultCompleter.future;

    // 5️⃣ EXIT PAGE
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
/* ======================================================
 * UI WIDGETS (UNCHANGED)
 * ====================================================== */

class _TopUserCard extends StatelessWidget {
  final String name;
  final String id;

  const _TopUserCard({required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          UserAvatarHelper.circleAvatar(
            userIdentification: id,
            displayName: name,
            radius: 24,
            localBytes: null,
            frameUrl: null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("ID:$id",
                  style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool requiredField;

  const _ReadOnlyRow({
    Key? key,
    required this.label,
    required this.value,
    this.requiredField = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// LABEL (LEFT)
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(text: label),
                  if (requiredField)
                    const TextSpan(
                      text: " *",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),

          /// VALUE (RIGHT, READ-ONLY)
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isNotEmpty ? value : "—",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextRowField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool requiredField;

  const _TextRowField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.requiredField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                style:
                const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: label),
                  if (requiredField)
                    const TextSpan(
                        text: " *", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle:
                const TextStyle(color: Colors.black38),
              ),
              validator: (v) {
                if (!requiredField) return null;
                if ((v ?? "").trim().isEmpty) return "Required";
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final void Function(File file) onPicked;

  const _ImagePickerBox({
    required this.label,
    required this.controller,
    required this.requiredField,
    required this.onPicked,
  });

  @override
  State<_ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<_ImagePickerBox> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      _imageFile = file;
      widget.controller.text = picked.path;
    });

    widget.onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style:
              const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: const Color(0xFFD6D6D6)),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity),
              )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 36, color: Colors.black45),
                  SizedBox(height: 8),
                  Text("Tap to upload",
                      style:
                      TextStyle(color: Colors.black45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
