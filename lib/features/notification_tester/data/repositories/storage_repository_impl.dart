import '../../domain/entities/history_item_entity.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/local_storage_datasource.dart';

class StorageRepositoryImpl implements IStorageRepository {
  final ILocalStorageDataSource dataSource;

  StorageRepositoryImpl({required this.dataSource});

  @override
  Future<void> saveServiceAccount(String rawJson) async {
    await dataSource.saveServiceAccountJson(rawJson);
  }

  @override
  Future<String?> getSavedServiceAccount() async {
    return await dataSource.getSavedServiceAccountJson();
  }

  @override
  Future<void> clearSavedServiceAccount() async {
    await dataSource.clearSavedServiceAccountJson();
  }

  @override
  Future<List<HistoryItemEntity>> getHistory() async {
    return await dataSource.getHistory();
  }

  @override
  Future<void> addHistoryItem(HistoryItemEntity item) async {
    final list = List<HistoryItemEntity>.from(await dataSource.getHistory());
    // Keep up to latest 50 items
    list.insert(0, item);
    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
    await dataSource.saveHistory(list);
  }

  @override
  Future<void> clearHistory() async {
    await dataSource.saveHistory([]);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final list = List<HistoryItemEntity>.from(await dataSource.getHistory());
    list.removeWhere((element) => element.id == id);
    await dataSource.saveHistory(list);
  }
}
