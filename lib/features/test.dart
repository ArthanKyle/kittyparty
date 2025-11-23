import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          'assets/icons/home.svg',
          width: 100,
        ),
      ),
    );
  }
}
