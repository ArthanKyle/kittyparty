import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final String url;
  final String? mime;

  const FullScreenMediaViewer({
    super.key,
    required this.url,
    required this.mime,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _controller;
  bool isVideo = false;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    isVideo = widget.mime?.startsWith("video") ?? false;

    if (isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (!mounted) return;
          _controller!.play();
          _controller!.setLooping(true);
          setState(() => isLoaded = true);
        });
    } else {
      isLoaded = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (_) => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: Stack(
          children: [
            Center(
              child: isVideo
                  ? _controller != null && _controller!.value.isInitialized
                  ? GestureDetector(
                onTap: () {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                  setState(() {});
                },
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
                  : const CircularProgressIndicator(color: Colors.white)
                  : InteractiveViewer(
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}