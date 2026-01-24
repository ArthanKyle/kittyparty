import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'banner_card.dart';

// ✅ Import where AppRoutes is defined (your MyApp file)
import 'package:kittyparty/app.dart'; // <-- change this to the exact file path where AppRoutes lives

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final List<String> images = const [
    'assets/image/banner/treasure-gold-coins-banner.jpg',
    'assets/image/banner/win-coin-back-banner.jpg',
    'assets/image/banner/couple-event-banner.jpg',
    'assets/image/banner/invite-banner.jpg',
    'assets/image/banner/monthly-recharge-banner.jpg',
    'assets/image/banner/pretty-id-banner.jpg',
    'assets/image/banner/wealth-level-reward-banner.jpg',
    'assets/image/banner/weekly-star-banner.jpg',
    'assets/image/banner/task-center-banner.jpg',
    'assets/image/banner/ad-event-banner.jpg',
  ];


  late final Map<String, String> bannerRouteByImage = {
    // EVENTS
    'assets/image/banner/treasure-gold-coins-banner.jpg':
    AppRoutes.treasureHunt,

    'assets/image/banner/monthly-recharge-banner.jpg':
    AppRoutes.monthlyRecharge,

    'assets/image/banner/wealth-level-reward-banner.jpg':
    AppRoutes.wealthReward,

    'assets/image/banner/weekly-star-banner.jpg':
    AppRoutes.weeklyStar,

    'assets/image/banner/couple-event-banner.jpg':
    AppRoutes.cpRanking,

    // NON-EVENT / EXISTING
    'assets/image/banner/win-coin-back-banner.jpg':
    AppRoutes.wallet,

    'assets/image/banner/invite-banner.jpg':
    AppRoutes.invite,

    'assets/image/banner/pretty-id-banner.jpg':
    AppRoutes.setting,

    'assets/image/banner/task-center-banner.jpg':
    AppRoutes.tasks,

    // ✅ INTENTIONAL FALLBACK
    'assets/image/banner/ad-event-banner.jpg':
    '/ad-event', // 👈 intentionally unmapped

  };


  int _currentIndex = 0;

  void _openBanner(BuildContext context, String imagePath, int index) {
    if (imagePath == 'assets/image/banner/ad-event-banner.jpg') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text(
            "Coming soon!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    final route = bannerRouteByImage[imagePath];
    if (route == null) return;

    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth / 4;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          options: CarouselOptions(
            height: bannerHeight,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final img = images[index];

            return BannerCard(
              height: bannerHeight,
              onTap: () => _openBanner(context, img, index),
              child: Image.asset(
                img,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
            final active = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: active ? 10 : 6,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
