import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../viewmodel/diamond_viewmodel.dart';

class DiamondCard extends StatefulWidget {
  final VoidCallback onConvert;

  const DiamondCard({
    super.key,
    required this.onConvert,
  });

  @override
  State<DiamondCard> createState() => _DiamondCardState();
}

class _DiamondCardState extends State<DiamondCard>
    with SingleTickerProviderStateMixin {
  late int oldBalance;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    oldBalance = 0;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiamondViewModel>(
      builder: (context, diamondVM, child) {
        final diamonds = diamondVM.diamond.diamonds;

        // Animate scale when diamonds change
        if (oldBalance != diamonds) {
          _scaleController.forward(from: 1.0).then((_) => _scaleController.reverse());
          oldBalance = diamonds;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.diamondGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Diamonds",
                          style: TextStyle(fontSize: 14, color: AppColors.gray),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleController.value,
                              child: TweenAnimationBuilder<int>(
                                tween: IntTween(begin: oldBalance, end: diamonds),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Text(
                                    value.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: widget.onConvert,
                          child: const Text(
                            "Convert >",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 170 - 35),
                  ],
                ),
              ),
              Positioned(
                top: -35,
                right: -35 / 2,
                child: Image.asset(
                  "assets/icons/jewel.PNG",
                  height: 170,
                  width: 170,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
