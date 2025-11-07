import 'package:flutter/material.dart';
import '../../../features/landing/landing_widgets/post_widgets/create_post_page.dart';
import '../../constants/colors.dart';

class CreatePostButton extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;

  const CreatePostButton({
    super.key,
    this.icon = Icons.videogame_asset,
    this.gradientColors = AppColors.buttonGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
        },
      ),
    );
  }
}
