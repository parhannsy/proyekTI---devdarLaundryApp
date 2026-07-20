import 'dart:async';
import '../models/models.dart';
import '../repositories/customer_repository.dart';
import 'mock_data_store.dart';

/// Implementasi mock yang menggunakan [MockDataStore.customers] —
/// data SAMA dengan yang dipakai [MockAuthRepository] untuk register.
class MockCustomerRepository implements CustomerRepository {
  List<UserModel> get _allCustomers => MockDataStore.customers;

  List<UserModel> get _sortedDesc => List.from(_allCustomers)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<UserModel>> getAllCustomers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _sortedDesc;
  }

  @override
  Future<CustomerPageResult> getCustomersPage({
    required int limit,
    Object? cursor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final sorted = _sortedDesc;

    int startIndex = 0;
    if (cursor != null) {
      startIndex = cursor as int;
      if (startIndex >= sorted.length) startIndex = sorted.length;
    }

    final endIndex = (startIndex + limit).clamp(0, sorted.length);
    final page = sorted.sublist(startIndex, endIndex);
    final hasMore = endIndex < sorted.length;

    return CustomerPageResult(
      customers: page,
      hasMore: hasMore,
      cursor: hasMore ? endIndex : null,
    );
  }

  @override
  Stream<List<UserModel>> streamCustomers() {
    final controller = StreamController<List<UserModel>>.broadcast();

    final timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!controller.isClosed) {
        controller.add(List.from(_allCustomers));
      }
    });

    controller.onCancel = () => timer.cancel();

    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(List.from(_allCustomers));
      }
    });

    return controller.stream;
  }

  @override
  Future<UserModel?> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _allCustomers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateCustomer(UserModel customer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _allCustomers.indexWhere((c) => c.id == customer.id);
    if (index == -1) throw Exception('Customer tidak ditemukan.');
    _allCustomers[index] = customer;
    return customer;
  }

  @override
  Future<void> deactivateCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _allCustomers.removeWhere((c) => c.id == id);
  }
}
