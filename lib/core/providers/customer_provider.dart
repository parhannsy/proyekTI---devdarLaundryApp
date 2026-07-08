import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  List<UserModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomerProvider(this._repository);

  List<UserModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCustomers => _customers.length;

  Future<void> loadAllCustomers() async {
    _setLoading(true);
    try {
      _customers = await _repository.getAllCustomers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCustomer(UserModel customer) async {
    try {
      final updated = await _repository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deactivateCustomer(String id) async {
    try {
      await _repository.deactivateCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
