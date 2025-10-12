import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _bestScoreKey = 'best_score';

  static Future<int> getBestScore() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_bestScoreKey) ?? 0;
  }

  static Future<void> setBestScore(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_bestScoreKey, value);
  }
}
