import '../entities/history_item_entity.dart';

abstract class IStorageRepository {
  Future<void> saveServiceAccount(String rawJson);
  Future<String?> getSavedServiceAccount();
  Future<void> clearSavedServiceAccount();

  Future<List<HistoryItemEntity>> getHistory();
  Future<void> addHistoryItem(HistoryItemEntity item);
  Future<void> clearHistory();
  Future<void> deleteHistoryItem(String id);
}
