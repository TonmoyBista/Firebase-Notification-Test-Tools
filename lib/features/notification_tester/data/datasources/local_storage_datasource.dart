import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_notification_test_tools/core/constants/app_constants.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/data/models/history_item_model.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/history_item_entity.dart';

abstract class ILocalStorageDataSource {
  Future<void> saveServiceAccountJson(String json);
  Future<String?> getSavedServiceAccountJson();
  Future<void> clearSavedServiceAccountJson();

  Future<List<HistoryItemEntity>> getHistory();
  Future<void> saveHistory(List<HistoryItemEntity> history);
}

class LocalStorageDataSourceImpl implements ILocalStorageDataSource {
  final SharedPreferences? prefs;

  LocalStorageDataSourceImpl({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveServiceAccountJson(String json) async {
    final p = await _getPrefs();
    await p.setString(AppConstants.keySavedServiceAccount, json);
  }

  @override
  Future<String?> getSavedServiceAccountJson() async {
    final p = await _getPrefs();
    return p.getString(AppConstants.keySavedServiceAccount);
  }

  @override
  Future<void> clearSavedServiceAccountJson() async {
    final p = await _getPrefs();
    await p.remove(AppConstants.keySavedServiceAccount);
  }

  @override
  Future<List<HistoryItemEntity>> getHistory() async {
    final p = await _getPrefs();
    final raw = p.getString(AppConstants.keyHistoryList);
    if (raw == null || raw.isEmpty) return [];
    return HistoryItemModel.decodeList(raw);
  }

  @override
  Future<void> saveHistory(List<HistoryItemEntity> history) async {
    final p = await _getPrefs();
    final encoded = HistoryItemModel.encodeList(history);
    await p.setString(AppConstants.keyHistoryList, encoded);
  }
}
