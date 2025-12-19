import 'package:flutter/cupertino.dart';
import 'package:kittyparty/core/global_widgets/toast/top_toast.dart';

import '../../../features/livestream/viewmodel/gift_event_viewmodel.dart';

class GiftBannerQueue {
  static final List<GiftEvent> _queue = [];
  static bool _showing = false;

  static void push(BuildContext context, GiftEvent event) {
    _queue.add(event);
    _tryNext(context);
  }

  static void _tryNext(BuildContext context) {
    if (_showing || _queue.isEmpty) return;

    _showing = true;
    final event = _queue.removeAt(0);

    TopToast.show(
      context,
      message: "🎁 ${event.senderId} sent ${event.giftName}",
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _showing = false;
      _tryNext(context);
    });
  }
}
