import '../entities/history_item_entity.dart';
import '../repositories/storage_repository.dart';

class ManageHistoryUseCase {
  final IStorageRepository repository;

  ManageHistoryUseCase(this.repository);

  Future<List<HistoryItemEntity>> getHistory() async {
    return await repository.getHistory();
  }

  Future<void> addHistory(HistoryItemEntity item) async {
    await repository.addHistoryItem(item);
  }

  Future<void> clearHistory() async {
    await repository.clearHistory();
  }

  Future<void> deleteHistory(String id) async {
    await repository.deleteHistoryItem(id);
  }

  Future<void> saveServiceAccount(String json) async {
    await repository.saveServiceAccount(json);
  }

  Future<String?> getSavedServiceAccount() async {
    return await repository.getSavedServiceAccount();
  }

  Future<void> clearSavedServiceAccount() async {
    await repository.clearSavedServiceAccount();
  }
}
