import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api/dailyTask_service.dart';
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

    final token = context.watch<UserProvider>().token;

    if (token != null && !_fetched) {
      _fetched = true;

      // ✅ defer fetch until build is done
      Future.microtask(() {
        context.read<DailyTaskViewModel>().fetchDailyTasks(token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyTaskViewModel>();
    final token = context.watch<UserProvider>().token;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E5),
      body: SafeArea(
        child: Column(
          children: [
            DailyTaskHeader(token: token),
            const TaskTabs(),
            const SizedBox(height: 8),

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
    );
  }
}
