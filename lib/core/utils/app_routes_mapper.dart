import '../../app.dart';

class AppRouteMapper {
  static String? fromBackend(String? key) {
    if (key == null) return null;

    switch (key) {
      case 'treasureHunt':
        return AppRoutes.treasureHunt;
      case 'monthlyRecharge':
        return AppRoutes.monthlyRecharge;
      case 'wealthReward':
        return AppRoutes.wealthReward;
      case 'weeklyStar':
        return AppRoutes.weeklyStar;
      case 'cpRanking':
        return AppRoutes.cpRanking;
      case 'wallet':
        return AppRoutes.wallet;
      case 'invite':
        return AppRoutes.invite;
      case 'setting':
        return AppRoutes.setting;
      case 'tasks':
        return AppRoutes.tasks;
      default:
        return null;
    }
  }
}
