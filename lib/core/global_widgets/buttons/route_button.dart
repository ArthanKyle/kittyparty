import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/colors.dart';


class RouteButton extends StatefulWidget {
  final String routeName;
  final String filePath;
  final VoidCallback routeCallback;
  final int currentIndex;
  final int routeIndex;

  const RouteButton({
    super.key,
    required this.routeName,
    required this.filePath,
    required this.routeCallback,
    required this.currentIndex,
    required this.routeIndex,
  });

  @override
  State<RouteButton> createState() => _RouteButtonState();
}

class _RouteButtonState extends State<RouteButton> {
  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentIndex == widget.routeIndex;

    return Container(
      constraints: const BoxConstraints(minWidth: 75),
      child: GestureDetector(
        onTap: widget.routeCallback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: AppColors.softGradient, // must be a List<Color>
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: SvgPicture.asset(
                  widget.filePath,
                  height: 40,
                  width: 40,
                ),
              )
            else
              SvgPicture.asset(
                widget.filePath,
                height: 25,
                width: 25,
                colorFilter: const ColorFilter.mode(
                  Color(0xffcbc9c9),
                  BlendMode.srcIn,
                ),
              ),
            const SizedBox(height: 2.5),
          ],
        ),
      ),
    );
  }
}