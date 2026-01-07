import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../../landing/landing_widgets/profile_widgets/daily_widgets/daily_task_header.dart';
import '../../landing/landing_widgets/profile_widgets/daily_widgets/daily_task_list.dart';
import '../../landing/landing_widgets/profile_widgets/daily_widgets/daily_task_tabs.dart';
import '../../landing/viewmodel/dailyTask_viewmodel.dart';

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = context.watch<UserProvider>();
    final uid = userProvider.currentUser?.userIdentification;

    if (!_fetched && uid != null && uid.trim().isNotEmpty) {
      _fetched = true;

      // Avoid setState/notify during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DailyTaskViewModel>().fetchDailyTasks(uid.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyTaskViewModel>();

    // For header (if you still need something displayed there)
    final userProvider = context.watch<UserProvider>();
    final uid = userProvider.currentUser?.userIdentification;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E5),
      body: Column(
        children: [
          DailyTaskHeader(userIdentification: uid),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const TaskTabs(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : vm.dailyTasks.isEmpty
                        ? const Center(child: Text("No daily tasks available"))
                        : DailyTaskList(viewModel: vm),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
