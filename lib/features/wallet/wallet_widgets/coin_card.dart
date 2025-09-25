import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CoinCard extends StatefulWidget {
  final int balance;

  const CoinCard({super.key, required this.balance});

  @override
  State<CoinCard> createState() => _CoinCardState();
}

class _CoinCardState extends State<CoinCard> with SingleTickerProviderStateMixin {
  late int oldBalance;
  late AnimationController _scaleController;
  final List<Widget> _particles = [];

  @override
  void initState() {
    super.initState();
    oldBalance = widget.balance;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  @override
  void didUpdateWidget(CoinCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      // Trigger pop animation
      _scaleController.forward(from: 1.0).then((_) => _scaleController.reverse());

      // Trigger floating coins
      _spawnParticles();

      oldBalance = oldWidget.balance;
    }
  }

  void _spawnParticles() {
    final random = Random();
    final newParticles = List.generate(5, (index) {
      final startX = random.nextDouble() * 60 - 30;
      final duration = random.nextInt(400) + 600;

      return FloatingCoin(
        key: UniqueKey(),
        startX: startX,
        duration: duration,
      );
    });

    setState(() {
      _particles.addAll(newParticles);
    });

    // Remove particles after animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double imageSize = 170.0;
    const double overlapAmount = 35.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12 + overlapAmount / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.goldShineGradient,
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
                    const Text("My Coins", style: TextStyle(fontSize: 14, color: AppColors.gray)),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleController.value,
                          child: TweenAnimationBuilder<int>(
                            tween: IntTween(begin: oldBalance, end: widget.balance),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Text(
                                value.toString(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text("Detail >", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                SizedBox(width: imageSize - overlapAmount),
              ],
            ),
          ),
          Positioned(
            top: -overlapAmount,
            right: -overlapAmount / 2,
            child: Image.asset(
              "assets/icons/KPcoin.png",
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            ),
          ),
          // Floating particles
          ..._particles,
        ],
      ),
    );
  }
}

class FloatingCoin extends StatefulWidget {
  final double startX;
  final int duration;

  const FloatingCoin({super.key, required this.startX, required this.duration});

  @override
  State<FloatingCoin> createState() => _FloatingCoinState();
}

class _FloatingCoinState extends State<FloatingCoin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    _yAnimation = Tween<double>(begin: 0, end: -80 - Random().nextDouble() * 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: 50 + widget.startX,
          top: 30 + _yAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Image.asset(
              "assets/icons/KPcoin.png",
              height: 24,
              width: 24,
            ),
          ),
        );
      },
    );
  }
}
