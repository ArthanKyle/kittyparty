import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';



class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: const Center(
          child: Text(
            'Blank Page',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
