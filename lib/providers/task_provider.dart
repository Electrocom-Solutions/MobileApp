import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  String? _filterProjectId;

  List<Task> get tasks {
    var filtered = _tasks;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.projectTitle.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((t) => t.status == _filterStatus).toList();
    }

    if (_filterProjectId != null) {
      filtered = filtered.where((t) => t.projectId == _filterProjectId).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  String? get filterProjectId => _filterProjectId;

  TaskProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _tasks = [
      Task(
        id: '1',
        name: 'Install CAT6 cabling',
        description: 'Install network cabling in conference room A',
        date: DateTime(now.year, now.month, now.day),
        createdAt: DateTime(now.year, now.month, now.day - 1),
        location: 'Mumbai, Maharashtra',
        timeTakenMinutes: 480,
        projectId: '1',
        projectTitle: 'Office Network Upgrade',
        status: TaskStatus.completed,
        attachments: [],
        resources: [
          ResourceUsed(
            id: 'r1',
            name: 'CAT6 Cable',
            quantity: 100,
            unit: 'm',
            unitCost: 25,
          ),
          ResourceUsed(
            id: 'r2',
            name: 'RJ45 Connectors',
            quantity: 20,
            unit: 'pcs',
            unitCost: 5,
          ),
        ],
      ),
      Task(
        id: '2',
        name: 'Configure router',
        description: 'Set up main office router with VLANs',
        date: DateTime(now.year, now.month, now.day - 1),
        createdAt: DateTime(now.year, now.month, now.day - 1),
        location: 'Mumbai, Maharashtra',
        timeTakenMinutes: 120,
        projectId: '1',
        projectTitle: 'Office Network Upgrade',
        status: TaskStatus.approved,
        attachments: [],
        resources: [],
      ),
      Task(
        id: '3',
        name: 'Install smart switches',
        description: 'Install and configure smart light switches in living room',
        date: DateTime(now.year, now.month, now.day),
        createdAt: DateTime(now.year, now.month, now.day),
        location: 'Pune, Maharashtra',
        timeTakenMinutes: 240,
        projectId: '2',
        projectTitle: 'Smart Home Installation',
        status: TaskStatus.inProgress,
        attachments: [],
        resources: [
          ResourceUsed(
            id: 'r3',
            name: 'Smart Switch',
            quantity: 5,
            unit: 'pcs',
            unitCost: 1500,
          ),
        ],
      ),
    ];
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterProject(String? projectId) {
    _filterProjectId = projectId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterProjectId = null;
    notifyListeners();
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
