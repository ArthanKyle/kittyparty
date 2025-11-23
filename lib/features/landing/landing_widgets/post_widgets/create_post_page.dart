import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../../viewmodel/post_viewmodel.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _picked = [];
  final Map<String, double> _uploadProgress = {};
  int maxLen = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final files = await _picker.pickMultiImage();
    if (files != null && files.isNotEmpty) {
      setState(() => _picked.addAll(files));
    }
  }

  Future<void> _submitPost(PostViewModel vm) async {
    final content = _controller.text.trim();
    if (content.isEmpty && _picked.isEmpty) return;

    // Check for currentUserId
    if (vm.currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final success = await vm.createPost(
      content: content,
      mediaFiles: _picked.map((x) => File(x.path)).toList(),
    );

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Failed to create post')),
      );
    }
  }


  Widget _buildMediaPreview(XFile file) {
    final progress = _uploadProgress[file.path] ?? 0.0;
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        if (progress > 0 && progress < 1.0)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        maxLength: maxLen,
                        onChanged: (_) => setState(() {}),   // ← FIX
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Record your life at this moment...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${_controller.text.length}/$maxLen'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickMedia,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, size: 48, color: Colors.white70),
                              ),
                            ),
                          ),
                          ..._picked.map(_buildMediaPreview).toList(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.posting ? null : () => _submitPost(vm),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: vm.posting
                              ? const CircularProgressIndicator()
                              : const Text(
                            'Post',
                            style: TextStyle(fontSize: 18, color: AppColors.accentWhite),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
