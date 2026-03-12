import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/team_service.dart';

class TeamProvider extends ChangeNotifier {
  final _teamService = TeamService();

  List<Team> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load teams
  Future<void> loadTeams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teams = await _teamService.getMyTeams();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

// Clear teams on logout
  void clearTeams() {
    _teams = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Create team
  Future<bool> createTeam({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _teamService.createTeam(
        name: name,
        description: description,
      );

      if (result['success']) {
        await loadTeams(); // Reload teams
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Join team
  Future<bool> joinTeam(String joinCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _teamService.joinTeam(joinCode);

      if (result['success']) {
        await loadTeams(); // Reload teams
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh teams
  Future<void> refreshTeams() async {
    await loadTeams();
  }
}
