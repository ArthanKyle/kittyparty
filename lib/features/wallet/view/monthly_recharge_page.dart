import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kittyparty/core/constants/colors.dart';
import 'package:kittyparty/core/global_widgets/buttons/gradient_button.dart';

class MonthlyRechargePage extends StatefulWidget {
  const MonthlyRechargePage({super.key});

  @override
  State<MonthlyRechargePage> createState() => _MonthlyRechargePageState();
}

class _MonthlyRechargePageState extends State<MonthlyRechargePage> {
  late DateTime targetTime;
  late Duration remaining;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    targetTime = DateTime.now().add(const Duration(days: 31));
    remaining = targetTime.difference(DateTime.now());
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = targetTime.difference(DateTime.now());
      if (diff.isNegative) {
        targetTime = DateTime.now().add(const Duration(days: 31));
        remaining = targetTime.difference(DateTime.now());
      } else {
        remaining = diff;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(title: const Text('Monthly Recharge')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _timeBox(context, two(days), 'DAY'),
                    _timeBox(context, two(hours), 'HOUR'),
                    _timeBox(context, two(minutes), 'MIN'),
                    _timeBox(context, two(seconds), 'SEC'),
                  ],
                ),
              ),
              Divider(),
              Text(
                'My Recharge',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('0.00', style: Theme.of(context).textTheme.headlineMedium),
              GradientButton(
                onPressed: () {},
                text: 'Go to Recharge',
                gradient: AppColors.goldShineGradient,
              ),

              Divider(),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => _listRewards(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _listRewards() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade200, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text('Recharge \$10'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Image.asset(
                  height: 250,
                  width: 90,
                  'assets/image/avatar_mall/520 Flower Profile Picture Frame.png',
                ),
              ),
              Column(
                spacing: 12,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(
                      height: 90,
                      width: 90,
                      'assets/image/avatar_mall/520 Flower Profile Picture Frame.png',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(
                      height: 90,
                      width: 90,
                      'assets/image/avatar_mall/520 Flower Profile Picture Frame.png',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GradientButton(
            text: 'Get Reward',

            onPressed: () {},
            gradient: AppColors.softGradient,
          ),
        ],
      ),
    );
  }

  Widget _timeBox(BuildContext context, String value, String label) {
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
