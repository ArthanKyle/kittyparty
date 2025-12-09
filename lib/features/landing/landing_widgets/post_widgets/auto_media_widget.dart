import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AutoMediaWidget extends StatefulWidget {
  final Map<String, dynamic> media; // { id, mime }
  final double height;

  const AutoMediaWidget({
    super.key,
    required this.media,
    this.height = 220,
  });

  @override
  State<AutoMediaWidget> createState() => _AutoMediaWidgetState();
}

class _AutoMediaWidgetState extends State<AutoMediaWidget> {
  VideoPlayerController? _controller;
  bool isVideo = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final mime = widget.media['mime'] ?? "";
    isVideo = mime.startsWith("video");

    if (isVideo) {
      final base = dotenv.env['BASE_URL']!;
      final url = "$base/media/${widget.media['id']}";

      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() => isLoading = false);
          _controller!.setLooping(true);
        });
    } else {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = dotenv.env['BASE_URL']!;
    final url = "$base/media/${widget.media['id']}";

    if (isVideo) {
      if (isLoading || !_controller!.value.isInitialized) {
        return _loadingBox();
      }

      return GestureDetector(
        onTap: () {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
          setState(() {});
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
              if (!_controller!.value.isPlaying)
                const Icon(Icons.play_circle_fill,
                    color: Colors.white, size: 60),
            ],
          ),
        ),
      );
    }

    // IMAGE
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorBox(),
      ),
    );
  }

  Widget _loadingBox() => Container(
    height: widget.height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade300,
    ),
    child: const CircularProgressIndicator(),
  );

  Widget _errorBox() => Container(
    height: widget.height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade200,
    ),
    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
  );
}
