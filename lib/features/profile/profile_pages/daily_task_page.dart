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
  int _activeTab = 0; // 0 = Daily, 1 = Weekly, 2 = Agent

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = context.watch<UserProvider>();
    final uid = userProvider.currentUser?.userIdentification;

    if (!_fetched && uid != null && uid.trim().isNotEmpty) {
      _fetched = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DailyTaskViewModel>().fetchDailyTasks(uid.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyTaskViewModel>();
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
                  TaskTabs(
                    activeIndex: _activeTab,
                    onChanged: (index) {
                      setState(() => _activeTab = index);
                    },
                  ),
                  const SizedBox(height: 20),

                  /// 🔽 CONTENT SWITCH
                  Expanded(child: _buildTabContent(vm)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(DailyTaskViewModel vm) {
    // DAILY TASKS
    if (_activeTab == 0) {
      if (vm.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (vm.dailyTasks.isEmpty) {
        return const Center(child: Text("No daily tasks available"));
      }

      return DailyTaskList(viewModel: vm);
    }

    // WEEKLY / AGENT → COMING SOON
    return const _ComingSoonView();
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.construction, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            "Coming Soon",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "This task category is under development.\nStay tuned for updates.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

