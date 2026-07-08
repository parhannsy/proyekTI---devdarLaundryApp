import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/mission_repository.dart';

class MissionProvider extends ChangeNotifier {
  final MissionRepository _repository;

  List<MissionModel> _missions = [];
  List<CustomerMissionProgress> _progresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  MissionProvider(this._repository);

  List<MissionModel> get missions => _missions;
  List<CustomerMissionProgress> get progresses => _progresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MissionModel> get activeMissions =>
      _missions.where((m) => m.isActive).toList();

  Future<void> loadAllMissions() async {
    _setLoading(true);
    try {
      _missions = await _repository.getAllMissions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCustomerProgress(String customerId) async {
    _setLoading(true);
    try {
      _missions = await _repository.getActiveMissions();
      _progresses = await _repository.getCustomerProgress(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  CustomerMissionProgress? getProgress(String missionId, String customerId) {
    try {
      return _progresses.firstWhere(
        (p) => p.missionId == missionId && p.customerId == customerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> createMission(MissionModel mission) async {
    try {
      final created = await _repository.createMission(mission);
      _missions.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMission(MissionModel mission) async {
    try {
      final updated = await _repository.updateMission(mission);
      final index = _missions.indexWhere((m) => m.id == mission.id);
      if (index != -1) {
        _missions[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteMission(String id) async {
    try {
      await _repository.deleteMission(id);
      _missions.removeWhere((m) => m.id == id);
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
