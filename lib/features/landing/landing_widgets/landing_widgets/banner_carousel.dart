import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'banner_card.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final List<String> images = [
    'assets/image/banner/treasure-gold-coins-banner.jpg',
    'assets/image/banner/win-coin-back-banner.jpg',
    'assets/image/banner/couple-event-banner.jpg',
    'assets/image/banner/invite-banner.jpg',
    'assets/image/banner/monthly-recharge-banner.jpg',
    'assets/image/banner/pretty-id-banner.jpg',
    'assets/image/banner/wealth-level-reward-banner.jpg',
    'assets/image/banner/weekly-star-banner.jpg',
    'assets/image/banner/win-coin-back-banner.jpg',
    'assets/image/banner/ad-event-banner.jpg',

  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth / 4; // 4:1 ratio (1920x480)

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          options: CarouselOptions(
            height: bannerHeight,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 1.0, // full width inside parent
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return BannerCard(
              height: bannerHeight,
              onTap: (){
                debugPrint("Banner ${index + 1} tapped!");
              },
              child: Image.asset(
                images[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover, // fits perfectly since ratio matches
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