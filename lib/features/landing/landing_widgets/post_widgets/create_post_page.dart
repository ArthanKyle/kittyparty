import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  int maxLen = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final List<XFile>? files = await _picker.pickMultiImage();
    if (files != null && files.isNotEmpty) {
      setState(() {
        _picked.addAll(files);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the page in its own ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (_) => PostViewModel(),
      child: Consumer<PostViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            body: GradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Post graphics and text',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                            'Record your life at this moment and share it with interesting people...',
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
                            ..._picked.map((f) {
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(f.path), fit: BoxFit.cover),
                                ),
                              );
                            }).toList(),
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
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: vm.posting
                                ? null
                                : () async {
                              final content = _controller.text.trim();
                              final mediaFiles = _picked.map((x) => File(x.path)).toList();
                              final success = await vm.createPost(
                                content: content,
                                authorId: 'CURRENT_USER_ID',
                                mediaFiles: mediaFiles,
                              );
                              if (success) {
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to create post')),
                                );
                              }
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF88D8F7), Color(0xFF8FA8FF)],
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: vm.posting
                                    ? const CircularProgressIndicator()
                                    : const Text('Post', style: TextStyle(fontSize: 18)),
                              ),
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
      ),
    );
  }
}
