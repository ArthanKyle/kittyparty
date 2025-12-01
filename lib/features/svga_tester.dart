import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:kittyparty/features/livestream/widgets/gift_assets.dart';

class SvgATesterPage extends StatefulWidget {
  const SvgATesterPage({super.key});

  @override
  State<SvgATesterPage> createState() => _SvgATesterPageState();
}

class _SvgATesterPageState extends State<SvgATesterPage>
    with SingleTickerProviderStateMixin {

  SVGAAnimationController? _controller;
  final SVGAParser _parser = SVGAParser();

  final List<String> _giftNames = [
    "Red Rose Bookstore",
    "Charming female singer",
    "rose string tone",
    "Rolex",
    "rose crystal bottle",
    "love bouquet",
    "wedding dress",
    "Romantic love songs",
    "lion beauty",
    "Wealth-Bringing Demon Mask",
    "Silver Crown Daughter",
    "Misty Valley White Tiger",
    "Donut",
    "9 red roses",
    "Bouquet of 5 white roses",
    "Goddess Letter",
    "love rose",
    "Love Gramophone",
  ];

  String? selectedName;
  String? status;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _playSVGA() async {
    if (selectedName == null) return;

    final svgaPath = GiftAssets.svga(selectedName!);

    print("===== SVGA TEST =====");
    print("SVGA : $svgaPath");

    setState(() => status = "Loading...");

    try {
      final video = await _parser.decodeFromAssets(svgaPath);

      _controller!.videoItem = video;
      _controller!.repeat();

      setState(() => status = "Playing...");
    } catch (e) {
      print("❌ Error loading SVGA: $e");
      setState(() => status = "Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SVGA Tester"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey.shade900,
              value: selectedName,
              decoration: InputDecoration(
                labelText: "Select Gift",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _giftNames.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedName = value;
                  status = null;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: _playSVGA,
              child: const Text("Play SVGA", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.white70, fontSize: 14)),

            const SizedBox(height: 20),

            // THE FIX — using correct SVGAImage signature
            Expanded(
              child: Center(
                child: SVGAImage(
                  _controller!,              // <-- positional argument only
                  fit: BoxFit.contain,       // works
                  clearsAfterStop: false,
                  allowDrawingOverflow: true,
                  filterQuality: FilterQuality.low,
                  preferredSize: const Size(300, 300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
