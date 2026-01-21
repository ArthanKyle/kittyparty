import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../landing/viewmodel/agency_viewmodel.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AgencyRegistrationApplicationPage extends StatefulWidget {
  final String title;
  final String initialDisplayName;
  final String initialUserId;
  final bool isCreateAgency;

  /// for APPLY only
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

  // URLs for images (upload flow not included here)
  final _agencyAvatarUrl = TextEditingController();
  final _agentIdCardUrl = TextEditingController();
  final _inviterPicUrl = TextEditingController();

  // create/apply shared
  final _agencyName = TextEditingController();
  final _contactCountry = TextEditingController(text: "+63");
  final _contactValue = TextEditingController();
  final _contactType = TextEditingController();
  final _inviterId = TextEditingController();

  // create only
  final _agencyDescription = TextEditingController();

  @override
  void dispose() {
    _agencyAvatarUrl.dispose();
    _agentIdCardUrl.dispose();
    _inviterPicUrl.dispose();
    _agencyName.dispose();
    _contactCountry.dispose();
    _contactValue.dispose();
    _contactType.dispose();
    _inviterId.dispose();
    _agencyDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = _TopUserCard(
      name: widget.initialDisplayName,
      id: widget.initialUserId,
    );

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
              top,
              const SizedBox(height: 14),

              // ✅ Create: Logo/Avatar optional but kept here (maps to logoUrl)
              _ImagePickerBox(
                label: widget.isCreateAgency ? "Agency Avatar" : "Agency Avatar*",
                controller: _agencyAvatarUrl,
                requiredField: !widget.isCreateAgency, // apply requires
              ),
              const SizedBox(height: 14),

              // ✅ Create requires agency name
              _TextRowField(
                label: "Agency Name*",
                hint: "Please enter",
                controller: _agencyName,
                requiredField: true,
              ),

              const SizedBox(height: 10),

              // ✅ Create: add description
              if (widget.isCreateAgency) ...[
                _TextRowField(
                  label: "Description",
                  hint: "Optional",
                  controller: _agencyDescription,
                  requiredField: false,
                ),
                const SizedBox(height: 10),
              ],

              // ✅ Apply needs contact info / type / ID card
              if (!widget.isCreateAgency) ...[
                _PhoneRow(
                  label: "Agent Contact Info*",
                  countryController: _contactCountry,
                  valueController: _contactValue,
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                _TextRowField(
                  label: "Contact type*",
                  hint: "Select (Phone / WhatsApp / Telegram / Email)",
                  controller: _contactType,
                  requiredField: true,
                ),
                const SizedBox(height: 14),
                _ImagePickerBox(
                  label: "Agent ID Card*",
                  controller: _agentIdCardUrl,
                  requiredField: true,
                ),
                const SizedBox(height: 14),
                _TextRowField(
                  label: "Inviter ID",
                  hint: "Please enter",
                  controller: _inviterId,
                  requiredField: false,
                ),
                const SizedBox(height: 14),
                _ImagePickerBox(
                  label: "Inviter Pic.",
                  controller: _inviterPicUrl,
                  requiredField: false,
                ),
              ],

              const SizedBox(height: 18),

              if (vm.error != null) ...[
                Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AgencyViewModel>();

    if (widget.isCreateAgency) {
      final ok = await vm.createAgency(
        name: _agencyName.text.trim(),
        description: _agencyDescription.text.trim(),
        logoUrl: _agencyAvatarUrl.text.trim().isEmpty
            ? null
            : _agencyAvatarUrl.text.trim(),
      );

      if (ok && mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    final code = widget.agencyCode ?? "";
    if (code.isEmpty) return;

    final ok = await vm.applyToJoin(
      agencyCode: code,
      agencyAvatarUrl: _agencyAvatarUrl.text.trim(),
      agencyName: _agencyName.text.trim(),
      agentContactCountryCode: _contactCountry.text.trim(),
      agentContactValue: _contactValue.text.trim(),
      contactType: _contactType.text.trim(),
      agentIdCardUrl: _agentIdCardUrl.text.trim(),
      inviterId: _inviterId.text.trim(),
      inviterPicUrl: _inviterPicUrl.text.trim().isEmpty
          ? null
          : _inviterPicUrl.text.trim(),
    );

    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

/* =========================
 * DATA CLASS (optional; kept if you still use it elsewhere)
 * ========================= */

class AgencyApplicationForm {
  final String agencyAvatarUrl;
  final String agencyName;
  final String agentContactCountryCode;
  final String agentContactValue;
  final String contactType;
  final String agentIdCardUrl;
  final String inviterId;
  final String inviterPicUrl;

  AgencyApplicationForm({
    required this.agencyAvatarUrl,
    required this.agencyName,
    required this.agentContactCountryCode,
    required this.agentContactValue,
    required this.contactType,
    required this.agentIdCardUrl,
    required this.inviterId,
    required this.inviterPicUrl,
  });
}

/* =========================
 * UI WIDGETS (unchanged)
 * ========================= */

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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2F6B2F),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "A",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("ID:$id", style: const TextStyle(color: Colors.black54)),
            ],
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: label),
                  if (requiredField) const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
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
                hintStyle: const TextStyle(color: Colors.black38),
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

class _PhoneRow extends StatelessWidget {
  final String label;
  final TextEditingController countryController;
  final TextEditingController valueController;
  final bool requiredField;

  const _PhoneRow({
    required this.label,
    required this.countryController,
    required this.valueController,
    required this.requiredField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: label),
                  if (requiredField) const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: TextFormField(
              controller: countryController,
              decoration: const InputDecoration(border: InputBorder.none),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: valueController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: "Please enter your phone number",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38),
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

  const _ImagePickerBox({
    required this.label,
    required this.controller,
    required this.requiredField,
  });

  @override
  State<_ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<_ImagePickerBox> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  final img =
                  await _picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, img);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final img =
                  await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, img);
                },
              ),
            ],
          ),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      widget.controller.text = picked.path; // ✅ stored
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(text: widget.label.replaceAll("*", "")),
                if (widget.requiredField)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 📷 TAPPABLE IMAGE PICKER
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6D6D6)),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 36, color: Colors.black45),
                  SizedBox(height: 8),
                  Text(
                    "Tap to upload",
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// HIDDEN / OPTIONAL PATH FIELD (for debugging or manual paste)
          TextFormField(
            controller: widget.controller,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: "Image path",
              hintStyle: TextStyle(color: Colors.black38),
            ),
            validator: (v) {
              if (!widget.requiredField) return null;
              if ((v ?? "")
                  .trim()
                  .isEmpty) return "Required";
              return null;
            },
          ),
        ],
      ),
    );
  }
}