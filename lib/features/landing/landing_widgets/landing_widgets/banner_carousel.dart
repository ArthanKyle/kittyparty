import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/services/api/banner_service.dart';
import '../../../../core/utils/app_routes_mapper.dart';
import '../../../../core/utils/remote_asset_helper.dart';
import '../../model/banner_item.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late Future<List<BannerItem>> _future;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = BannerService.fetchBanners();
  }

  void _openBanner(BuildContext context, BannerItem banner) {
    final route = AppRouteMapper.fromBackend(banner.route);

    if (route == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text(
            "Coming soon!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth / 4;

    return FutureBuilder<List<BannerItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: bannerHeight,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final banners = snapshot.data!;

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              options: CarouselOptions(
                height: bannerHeight,
                autoPlay: true,
                viewportFraction: 1,
                onPageChanged: (i, _) =>
                    setState(() => _currentIndex = i),
              ),
              itemBuilder: (context, index, _) {
                final banner = banners[index];

                return GestureDetector(
                  onTap: () => _openBanner(context, banner),
                  child: FutureBuilder<File>(
                    future: RemoteAssetHelper.load(banner.image),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      return Image.file(
                        snap.data!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) {
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
      },
    );
  }
}
