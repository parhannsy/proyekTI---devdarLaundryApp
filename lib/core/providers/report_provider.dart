import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;

  ReportSummary? _summary;
  DateTime _from;
  DateTime _to;
  bool _isLoading = false;
  String? _errorMessage;

  ReportProvider(this._repository)
      : _from = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        ),
        _to = DateTime.now();

  ReportSummary? get summary => _summary;
  DateTime get from => _from;
  DateTime get to => _to;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSummary() async {
    _setLoading(true);
    try {
      _summary = await _repository.getSummary(from: _from, to: _to);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeDateRange(DateTime from, DateTime to) async {
    _from = from;
    _to = to;
    await loadSummary();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
